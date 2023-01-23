require "./telegram_service/*"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add event handlers to it.
  @[ADI::Register(public: true)]
  class TelegramService
    include Logger
    include CoreMethods
    include SugarMethods

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot` to `get_me`.
    getter! bot : Model::User

    @pool : DB::Pool(HTTP::Client)

    def initialize
      if Config.proxy
        if uri = Config.proxy_uri?
          uri = uri.is_a?(URI) ? uri : URI.parse(uri.starts_with?("http") ? uri : "http://#{uri}")
          Config.proxy_host = uri.host
          Config.proxy_port = uri.port
          Config.proxy_user = uri.user if uri.user
          Config.proxy_pass = uri.password if uri.password
        end

        if Config.proxy_host && Config.proxy_port
          proxy = HTTP::Proxy::Client.new(Config.proxy_host, Config.proxy_port, username: Config.proxy_user, password: Config.proxy_pass)
        end
      end

      @pool = DB::Pool(HTTP::Client).new(max_pool_size: 200, initial_pool_size: 20, checkout_timeout: 0.1) do
        client = HTTP::Client.new(URI.parse(Config.api_endpoint))
        client.set_proxy(proxy.dup) if proxy
        client
      end

      @bot = self.get_me
    end

    def use(middleware : Middleware)
      @middlewares << middleware
    end

    # Add an `EventHandler` instance to the handler stack
    def add_event_handler(handler : EventHandler)
      @event_handlers << handler
    end

    # Remove an existing event handler from the stack
    def remove_event_handler(handler : EventHandler)
      @event_handlers.delete(handler)
    end

    protected def using_connection
      @pool.retry do
        @pool.checkout do |conn|
          yield conn
        end
      end
    end

    protected def request(type : U.class, method, params = {} of String => String) forall U
      path = File.join("/bot#{Config.api_token}", method)
      response = request(path, params)
      type.from_json(response)
    end

    # Sends a json request to the Telegram Client API.
    protected def request(path, params = {} of String => String)
      multipart = includes_media(params)

      # Wrap this so pool can attempt a retry
      using_connection do |client|
        Log.debug { "sending ►► #{path.split("/").last}(#{params.to_pretty_json})" }

        begin
          if multipart
            config = build_form_data_config(params)
            response = client.exec(**config, path: path)
          else
            config = build_json_config(params)
            response = client.exec(**config, path: path)
          end
        rescue ex : IO::Error | IO::TimeoutError
          Log.error { ex.message }
          Log.trace(exception: ex) { ex.message }

          raise Exceptions::ConnectionLost.new(client)
        end

        result = JSON.parse(response.body)

        Log.debug { "receiving ◄◄ #{result.to_pretty_json}" }

        if result["ok"].as_bool
          result["result"].to_json
        else
          raise Exceptions::Error.from_message(result["description"].as_s)
        end
      end
    end

    protected def object_or_id(object)
      if object.responds_to?(:id)
        return object.id
      end
      object
    end

    protected def includes_media(params)
      params.values.any? do |val|
        case val
        when Array
          val.any? { |v| v.is_a?(File | Tourmaline::Model::InputMedia) }
        when File, Tourmaline::Model::InputMedia
          true
        else
          false
        end
      end
    end

    protected def build_json_config(payload)
      {
        method:  "POST",
        headers: HTTP::Headers{"Content-Type" => "application/json", "Connection" => "keep-alive"},
        body:    payload.to_h.compact.to_json,
      }
    end

    protected def build_form_data_config(payload)
      boundary = MIME::Multipart.generate_boundary
      formdata = MIME::Multipart.build(boundary) do |form|
        payload.each do |key, value|
          attach_form_value(form, key.to_s, value)
        end
      end

      {
        method:  "POST",
        headers: HTTP::Headers{
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        body: formdata,
      }
    end

    protected def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
      return unless value
      headers = HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}"}

      case value
      when Array
        # Likely an Array(InputMedia)
        items = value.map do |item|
          if item.is_a?(Tourmaline::Model::InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when Tourmaline::Model::InputMedia
        attach_form_media(form, value)
        form.body_part(headers, value.to_json)
      when File
        filename = File.basename(value.path)
        form.body_part(
          HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
          value
        )
      else
        form.body_part(headers, value.to_s)
      end
    end

    protected def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
      media = value.media
      thumb = value.responds_to?(:thumb) ? value.thumb : nil

      {media: media, thumb: thumb}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(File)
          id = Random.new.random_bytes(16).hexstring
          filename = File.basename(item.path)

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumb)
            value.thumb = "attach://#{id}"
          end
        end
      end
    end

    protected def check_open_local_file(file)
      if file.is_a?(String)
        begin
          if File.file?(file)
            return File.open(file)
          end
        rescue ex
        end
      end
      file
    end

    protected def register_commands_with_botfather
      commands = [] of Handlers::CommandHandler
      @event_handlers.each { |h| commands << h if h.is_a?(Handlers::CommandHandler) }

      registerable = commands
        .select { |c| c.register && c.description && !c.description.to_s.empty? }
        .select { |c| c.prefixes.includes?("/") }

      if registerable.size > 100
        Log.warn {
          "Only a maximum of 100 commands may be registered with BotFather at a time.\n" \
          "Registering the first 100"
        }
      end

      bot_commands = registerable[..100].map do |c|
        {command: c.register_as || c.commands[0], description: c.description.to_s}
      end

      set_my_commands(bot_commands) if @set_commands
    end
  end
end
