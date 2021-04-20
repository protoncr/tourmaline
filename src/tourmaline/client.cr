require "./annotations"
require "./helpers"
require "./error"
require "./logger"
require "./persistence"
require "./parse_mode"
require "./container"
require "./chat_action"
require "./model"
require "./update_action"
require "./event_handler"
require "./middleware"
require "./client/*"
require "db/pool"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add event handlers to it.
  class Client
    macro inherited
      include Tourmaline
    end

    include Logger

    include CoreMethods
    include GameMethods
    include PassportMethods
    include PaymentMethods
    include PollMethods
    include StickerMethods
    include WebhookMethods
    include TDLightMethods

    include EventHandler::Annotator

    DEFAULT_API_URL          = "https://api.telegram.org/"
    DEFAULT_COMMAND_PREFIXES = ["/"]

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot` to `get_me`.
    getter bot : User { get_me }

    property bot_token : String?
    property user_token : String?

    # Default parse mode to use for commands when it isn't included explicitly
    property default_parse_mode : ParseMode

    # Default prefixes to use for commands
    class_property default_command_prefixes : Array(String) = DEFAULT_COMMAND_PREFIXES

    private getter event_handlers : Array(EventHandler)
    private getter persistence : Persistence
    private getter middlewares : Array(Middleware | MiddlewareProc)

    @pool : DB::Pool(HTTP::Client)
    @auth_code : String?

    # Create a new instance of `Tourmaline::Client`.
    #
    # ## Named Arguments
    #
    # `bot_token`
    # :    the bot token you should've received from `@BotFather`
    #
    # `user_token`
    # :    the token returned by the `#login` method
    #
    # `endpoint`
    # :    the API endpoint to use for requests; default is `https://api.telegram.org`, but for
    #      TDLight methods to work you may consider hosting your own instance or using one of
    #      the official ones such as `https://telegram.rest`
    #
    # `persistence`
    # :    the persistence strategy to use
    #
    # `set_commands`
    # :    if true, `set_my_commands` will be run on start and any commands marked with `register`
    #      will be registered with BotFather.
    #
    # `pool_capacity`
    # :    the maximum number of concurrent HTTP connections to use
    #
    # `initial_pool_size`
    # :    the number of HTTP::Client instances to create on init
    #
    # `pool_timeout`
    # :    How long to wait for a new client to be available if the pool is full before throwing a `TimeoutError`
    #
    # `proxy`
    # :    an instance of `HTTP::Proxy::Client` to use; if set, overrides the following `proxy_` args
    #
    # `proxy_uri`
    # :    a URI to use when connecting to the proxy; can be a `URI` instance or a String
    #
    # `proxy_host`
    # :    if no `proxy_uri` is provided, this will be the host for the URI
    #
    # `proxy_port`
    # :    if no `proxy_uri` is provided, this will be the port for the URI
    #
    # `proxy_user`
    # :    a username to use for a proxy that requires authentication
    #
    # `proxy_pass`
    # :    a password to use for a proxy that requires authentication
    def initialize(*,
                   @bot_token : String? = nil,
                   @user_token : String? = nil,
                   @endpoint = DEFAULT_API_URL,
                   @persistence : Persistence = NilPersistence.new,
                   @set_commands = false,
                   @default_parse_mode : ParseMode = ParseMode::Markdown,
                   pool_capacity = 200,
                   initial_pool_size = 20,
                   pool_timeout = 0.1,
                   proxy = nil,
                   proxy_uri = nil,
                   proxy_host = nil,
                   proxy_port = nil,
                   proxy_user = nil,
                   proxy_pass = nil)
      @persistence = persistence
      @persistence.init

      @middlewares = [] of Middleware | MiddlewareProc

      if !proxy
        if proxy_uri
          proxy_uri = proxy_uri.is_a?(URI) ? proxy_uri : URI.parse(proxy_uri.starts_with?("http") ? proxy_uri : "http://#{proxy_uri}")
          proxy_host = proxy_uri.host
          proxy_port = proxy_uri.port
          proxy_user = proxy_uri.user if proxy_uri.user
          proxy_pass = proxy_uri.password if proxy_uri.password
        end

        if proxy_host && proxy_port
          proxy = HTTP::Proxy::Client.new(proxy_host, proxy_port, username: proxy_user, password: proxy_pass)
        end
      end

      @pool = DB::Pool(HTTP::Client).new(max_pool_size: pool_capacity, initial_pool_size: initial_pool_size, checkout_timeout: pool_timeout) do
        client = HTTP::Client.new(URI.parse(endpoint))
        client.set_proxy(proxy.dup) if proxy
        client
      end

      @event_handlers = [] of EventHandler
      register_event_handler_annotations

      register_commands_with_botfather if @bot_token

      # FIXME: Find a way to support multiple clients while allowing models
      # to include an instance of the client that created them.
      Container.client = self

      Signal::INT.trap { exit }
    end

    def use(middleware : Middleware)
      @middlewares << middleware
    end

    # Add an `EventHandler` instance to the handler stack
    def add_event_handler(handler : EventHandler)
      @event_handlers << handler
      @event_handlers.sort! { |a, b| b.priority <=> a.priority }
      @event_handlers
    end

    # Remove an existing event handler from the stack
    def remove_event_handler(handler : EventHandler)
      @event_handlers.delete(handler)
    end

    # Calls all handlers in the stack with the given update and
    # this client instance.
    def handle_update(update : Update)
      handled = [] of String

      # First call middlewares
      @middlewares.each do |middleware|
        middleware.call(self, update)
      end

      # Then call individual event handlers
      {% if flag?(:no_async) %}
        @event_handlers.each do |handler|
          unless handled.includes?(handler.group)
            if handler.call(self, update)
              @persistence.handle_update(update)
              handled << handler.group
            end
          end
        end
      {% else %}
        @event_handlers.each do |handler|
          spawn do
            unless handled.includes?(handler.group)
              if handler.call(self, update)
                @persistence.handle_update(update)
                handled << handler.group
              end
            end
          end
        end
      {% end %}
    end

    private def request(type : U.class, method, params = {} of String => String) forall U
      if bot_token = @bot_token
        path = File.join("/bot#{bot_token}", method)
      else
        if method == "login"
          path = "/userlogin"
        elsif user_token = @user_token
          path = File.join("/user#{user_token}", method)
        else
          raise "Attempted to call API method without bot_token or user_token"
        end
      end

      response = request(path, params)
      type.from_json(response)
    end

    # Sends a json request to the Telegram Client API.
    private def request(path, params = {} of String => String)
      multipart = includes_media(params)

      # Wrap this so pool can attempt a retry
      @pool.checkout do |client|
        Log.debug { "sending ►► #{path.split("/").last}(#{params.to_pretty_json})" }

        if multipart
          config = build_form_data_config(params)
          response = client.exec(**config, path: path)
        else
          config = build_json_config(params)
          response = client.exec(**config, path: path)
        end

        result = JSON.parse(response.body)

        Log.debug { "receiving ◄◄ #{result.to_pretty_json}" }

        if result["ok"].as_bool
          result["result"].to_json
        else
          raise Error.from_message(result["description"].as_s)
        end
      end
    rescue IO::TimeoutError
      raise Error::RequestTimeoutError.new
    end

    private def object_or_id(object)
      if object.responds_to?(:id)
        return object.id
      end
      object
    end

    private def includes_media(params)
      params.values.any? do |val|
        case val
        when Array
          val.any? { |v| v.is_a?(File | InputMedia) }
        when File, InputMedia
          true
        else
          false
        end
      end
    end

    private def build_json_config(payload)
      {
        method:  "POST",
        headers: HTTP::Headers{"Content-Type" => "application/json", "Connection" => "keep-alive"},
        body:    payload.to_h.compact.to_json,
      }
    end

    private def build_form_data_config(payload)
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

    private def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
      return unless value
      headers = HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}"}

      case value
      when Array
        # Likely an Array(InputMedia)
        items = value.map do |item|
          if item.is_a?(InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when InputMedia
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

    private def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
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

    private def check_open_local_file(file)
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

    private def register_commands_with_botfather
      commands = [] of Handlers::CommandHandler
      @event_handlers.each { |h| commands << h if h.is_a?(Handlers::CommandHandler) }

      registerable = commands
        .select { |c| c.register && c.description && !c.description.to_s.empty? }
        .select { |c| c.prefixes.includes?("/") }
        .sort { |a, b| b.priority <=> a.priority }

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
