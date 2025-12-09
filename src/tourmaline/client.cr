require "./helpers"
require "./error"
require "./logger"
require "./parse_mode"
require "./chat_action"
require "./update_action"
require "./keyboard_builder"
require "./types/**"
require "./context"
require "./middleware"
require "./event_handler"
require "./dispatcher"
require "./poller"
require "./server"
require "./handlers/*"
require "./client/**"

require "db/pool"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add event handlers to it.
  class Client
    include Api
    include Logger

    DEFAULT_API_URL = "https://api.telegram.org/"

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot` to `get_me`.
    getter! bot : User

    getter bot_token : String

    property default_parse_mode : ParseMode

    @dispatcher : Dispatcher?

    @rate_limiter : RateLimiter::Limiter?

    private getter pool : DB::Pool(HTTP::Client)

    # Create a new instance of `Tourmaline::Client`.
    #
    # ## Named Arguments
    #
    # `bot_token`
    # :    the bot token you should've received from `@BotFather`
    #
    # `endpoint`
    # :    the API endpoint to use for requests; default is `https://api.telegram.org`, but for
    #      TDLight methods to work you may consider hosting your own instance or using one of
    #      the official ones such as `https://telegram.rest`
    #
    # `default_parse_mode`
    # :    the default parse mode to use for messages; default is `ParseMode::None` (no formatting)
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
    def initialize(@bot_token : String,
                   @endpoint = DEFAULT_API_URL,
                   @default_parse_mode : ParseMode = ParseMode::Markdown,
                   pool_capacity = 200,
                   initial_pool_size = 20,
                   pool_timeout = 0.1,
                   proxy = nil,
                   proxy_uri = nil,
                   proxy_host = nil,
                   proxy_port = nil,
                   proxy_user = nil,
                   proxy_pass = nil,
                   @rate_limiter = RateLimiter.new(interval: 1.second / 30)
                   )
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
        client.proxy = proxy.dup if proxy
        client
      end

      @bot = self.get_me
    end

    def dispatcher
      @dispatcher ||= Dispatcher.new(self)
    end

    def on(action : UpdateAction, &block : Context ->)
      dispatcher.on(action, &block)
    end

    def on(*actions : Symbol | UpdateAction, &block : Context ->)
      actions.each do |action|
        action = UpdateAction.parse(action.to_s) if action.is_a?(Symbol)
        dispatcher.on(action, &block)
      end
    end

    def use(middleware : Middleware)
      dispatcher.use(middleware)
    end

    def register(*handlers : EventHandler)
      handlers.each do |handler|
        dispatcher.register(handler)
      end
    end

    def poll
      Poller.new(self).start
    end

    def serve(path = "/", host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false)
      Server.new(self).serve(path, host, port, ssl_certificate_path, ssl_key_path, no_middleware_check)
    end

    protected def using_connection
      @pool.retry do
        @pool.checkout do |conn|
          yield conn
        end
      end
    end

    # :nodoc:
    MULTIPART_METHODS = %w(sendAudio sendDocument sendPhoto sendVideo sendAnimation sendVoice sendVideoNote sendMediaGroup)

    # Sends a request to the Telegram Client API. Returns the raw response.
    def request_raw(method : String, params = {} of String => String)
      path = "/bot#{bot_token}/#{method}"
      request_internal(path, params, multipart: MULTIPART_METHODS.includes?(method))
    end

    # Sends a request to the Telegram Client API. Returns the response, parsed as a `U`.
    def request(type : U.class, method, params = {} of String => String) forall U
      response = request_raw(method, params)
      type.from_json(response)
    end

    # :nodoc:
    def request_internal(path, params = {} of String => String, multipart = false)
      # Wrap this so pool can attempt a retry
      using_connection do |client|
        @rate_limiter.try &.get
        Log.debug { "sending ►► #{path.split("/").last}(#{params.to_pretty_json})" }

        begin
          if multipart
            config = build_form_data_config(params)
            response = client.exec(**config.merge({path: path}))
          else
            config = build_json_config(params)
            response = client.exec(**config.merge({path: path}))
          end
        rescue ex : IO::Error | IO::TimeoutError
          Log.error { ex.message }
          Log.trace(exception: ex) { ex.message }

          raise Error::ConnectionLost.new(client)
        end

        result = JSON.parse(response.body)

        Log.debug { "receiving ◄◄ #{result.to_pretty_json}" }

        if result["ok"].as_bool
          result["result"].to_json
        else
          raise Error.from_message(result["description"].as_s)
        end
      end
    end

    protected def extract_id(object)
      return if object.nil?
      if object.responds_to?(:id)
        return object.id
      elsif object.responds_to?(:message_id)
        return object.message_id
      elsif object.responds_to?(:file_id)
        return object.file_id
      elsif object.responds_to?(:to_i)
        return object.to_i
      end
      raise ArgumentError.new("Expected object with id or message_id, or integer, got #{object.class}")
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
          if item.is_a?(InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when InputMedia
        attach_form_media(form, value)
        form.body_part(headers, value.to_json)
      when ::File
        filename = ::File.basename(value.path)
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
      thumbnail = value.responds_to?(:thumbnail) ? value.thumbnail : nil

      {media: media, thumbnail: thumbnail}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(::File)
          id = Random.new.random_bytes(16).hexstring
          filename = ::File.basename(item.path)

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumbnail)
            value.thumbnail = "attach://#{id}"
          end
        end
      end
    end

    protected def check_open_local_file(file)
      if file.is_a?(String)
        begin
          if ::File.file?(file)
            return ::File.open(file)
          end
        rescue ex
        end
      end
      file
    end
  end
end
