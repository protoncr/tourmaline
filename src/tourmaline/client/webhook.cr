module Tourmaline
  class Client
    # Start an HTTP server at the specified `address` and `port` that listens for
    # updates using Telegram's webhooks. This is the reccommended way to handle
    # bots in production.
    def serve(address = "127.0.0.1", port = 8080, ssl_certificate_path = nil, ssl_key_path = nil)
      server = HTTP::Server.new do |context|
        begin
          Fiber.current.telegram_bot_server_http_context = context
          handle_update(Update.from_json(context.request.body.not_nil!))
        rescue exception
          Log.error { exception.message.to_s }
        ensure
          Fiber.current.telegram_bot_server_http_context = nil
        end
      end

      server.bind_tcp address, port
      server.listen
      if ssl_certificate_path && ssl_key_path
        fl_use_ssl = true
        ssl = OpenSSL::SSL::Context::Server.new
        ssl.certificate_chain = ssl_certificate_path.not_nil!
        ssl.private_key = ssl_key_path.not_nil!
        server.bind_tls address, port, ssl
      else
        server.bind_tcp address, port
      end

      Log.info { "Listening for Telegram requests at #{address}:#{port}#{" with tls" if fl_use_ssl}" }
      server.listen
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
    def set_webhook(url, certificate = nil, max_connections = nil, allowed_updates = @allowed_updates)
      params = {url: url, max_connections: max_connections, allowed_updates: allowed_updates, certificate: certificate}
      Log.info { "Setting webhook to '#{url}'#{" with certificate" if certificate}" }
      request("setWebhook", params)
    end

    # Use this to unset the webhook and stop receiving updates to your bot.
    def unset_webhook
      request("setWebhook", {url: ""})
    end

    # Use this method to get current webhook status. Requires no parameters.
    # On success, returns a `WebhookInfo` object. If the bot is using
    # `#getUpdates`, will return an object with the
    # url field empty.
    def get_webhook_info
      response = request("getWebhookInfo")
      WebhookInfo.from_json(response)
    end

    # Use this method to remove webhook integration if you decide to switch
    # back to getUpdates.
    def delete_webhook
      response = request("deleteWebhook")
      response == "true"
    end
  end
end
