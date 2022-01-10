require "kemal"

module Tourmaline
  # Tourmaline adapter for Kemal.
  #
  # This handler allows you to use Tourmaline as a part of your
  # Kemal server rather than as a standalone server. This means
  # that webhook requests can be sent to a specific path
  # and handled accordingly.
  class KemalAdapter(T) < Kemal::Handler
    property bot : T

    property url : String

    property path : String

    # Create a new instance of `TourmalineHandler`
    #
    # Requires a `bot` instance, a `url`, and an optional `path`.
    # The `url` needs to be the publically accessable URL for the
    # Kemal server. The `path` defines where this will be served on your
    # kemal instance. By default this is at `/webhook/{bot.name}`, but
    # it is recommended to use your bot's API key somewhere in the
    # path for security reasons.
    def initialize(
      @bot : T,
      @url : String,
      path = nil,
      certificate = nil,
      max_connections = nil
    )
      {% unless T <= Tourmaline::Client %}
        {% raise "bot must be an instance of Tourmaline::Client" %}
      {% end %}

      check_config

      @path = path || "/webhook/#{bot.bot.username}"

      # Only match on this path
      only([@path], "POST")

      # Set the webhook
      set_webhook(certificate, max_connections)
    end

    def check_config
      raise "Tourmaline bot webhooks require ssl." unless @url.starts_with?("https")

      ["10.", "172.", "192.", "100."].each do |ippart|
        raise "Cannot serve a Tourmaline bot webhook locally. Please use Ngrok for local testing." if @url.starts_with?(ippart)
      end
    end

    def set_webhook(certificate = nil, max_connections = nil)
      webhook_path = File.join(@url, @path)
      @bot.set_webhook(webhook_path, certificate, max_connections)
    end

    def unset_webhook
      @bot.unset_webhook
    end

    def call(context)
      return call_next(context) unless only_match?(context)

      if body = context.request.body
        update = Update.from_json(body)
        @bot.handle_update(update)
      end
    end
  end
end
