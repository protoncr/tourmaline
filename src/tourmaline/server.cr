module Tourmaline
  # The `Server` class is a basic webhook server for receiving
  # updates from the Telegram API.
  class Server
    @server : HTTP::Server?

    def initialize(client : Tourmaline::Client)
      @client = client
    end

    # Start an HTTP server at the specified `host` and `port` that listens for
    # updates using Telegram's webhooks.
    def serve(host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false, &block : HTTP::Server::Context ->)
      @server = server = HTTP::Server.new do |context|
        Fiber.current.telegram_bot_server_http_context = context
        begin
          block.call(context)
        rescue ex
          Log.error(exception: ex) { "Server error" }
        ensure
          Fiber.current.telegram_bot_server_http_context = nil
        end
      end

      if ssl_certificate_path && ssl_key_path
        fl_use_ssl = true
        ssl = OpenSSL::SSL::Context::Server.new
        ssl.certificate_chain = ssl_certificate_path.not_nil!
        ssl.private_key = ssl_key_path.not_nil!
        server.bind_tls(host: host, port: port, context: ssl)
      else
        server.bind_tcp(host: host, port: port)
      end

      Log.info { "Listening for requests at #{host}:#{port}" }
      server.listen
    end

    # :ditto:
    def serve(path = "/", host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false)
      serve(host, port, ssl_certificate_path, ssl_key_path, no_middleware_check) do |context|
        next unless context.request.method == "POST"
        next unless context.request.path == path
        if body = context.request.body
          update = Update.from_json(body)
          @client.dispatcher.process(update)
        end
      end
    end

    # Stops the webhook HTTP server
    def stop_serving
      @server.try &.close
    end
  end
end
