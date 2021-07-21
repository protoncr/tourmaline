module Tourmaline
  class Client
    module WebhookMethods
      include Logger

      # Start an HTTP server at the specified `host` and `port` that listens for
      # updates using Telegram's webhooks. This is the reccommended way to handle
      # bots in production.
      #
      # Note: Don't forget to call `set_webhook` first! This method does not do it for you.
      def serve(host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, &block : HTTP::Server::Context ->)
        @webhook_server = server = HTTP::Server.new do |context|
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
      def serve(path = "/", host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil)
        serve(host, port, ssl_certificate_path, ssl_key_path) do |context|
          next unless context.request.method == "POST"
          next unless context.request.path == path
          if body = context.request.body
            update = Update.from_json(body)
            handle_update(update)
          end
        end
      end

      # Stops the webhook HTTP server
      def stop_serving
        @webhook_server.try &.close
      end

      # Use this method to specify a url and receive incoming updates via an outgoing webhook.
      # Whenever there is an update for the bot, we will send an HTTPS POST request to the
      # specified url, containing a JSON-serialized `Update`. In case of an unsuccessful
      # request, we will give up after a reasonable amount of attempts.
      # Returns `true` on success.
      #
      # If you'd like to make sure that the Webhook request comes from Telegram, we recommend
      # using a secret path in the URL, e.g. `https://www.example.com/<token>`. Since nobody
      # else knows your bot‘s token, you can be pretty sure it’s us.
      def set_webhook(
        url,
        ip_address = nil,
        certificate = nil,
        max_connections = nil,
        allowed_updates = nil,
        drop_pending_updates = false
      )
        params = {
          url:                  url,
          ip_address:           ip_address,
          max_connections:      max_connections,
          allowed_updates:      allowed_updates,
          certificate:          certificate,
          drop_pending_updates: drop_pending_updates,
        }
        Log.info { "Setting webhook to '#{url}'#{" with certificate" if certificate}" }
        request(Bool, "setWebhook", params)
      end

      # Use this to unset the webhook and stop receiving updates to your bot.
      def unset_webhook
        request(Bool, "setWebhook", {url: ""})
      end

      # Use this method to get current webhook status. Requires no parameters.
      # On success, returns a `WebhookInfo` object. If the bot is using
      # `#getUpdates`, will return an object with the
      # url field empty.
      def get_webhook_info
        request(WebhookInfo, "getWebhookInfo")
      end

      # Use this method to remove webhook integration if you decide to switch
      # back to getUpdates.
      def delete_webhook(drop_pending_updates = false)
        request(Bool, "deleteWebhook", {
          drop_pending_updates: drop_pending_updates,
        })
      end
    end
  end
end
