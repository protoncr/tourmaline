module Tourmaline::Bot
  # Tourmaline's middleware acts very much like any other
  # server middleware. All updates that get sent to your
  # bot get passed through any registered middleware.
  # Using middleware you can filter or modify data
  # before it makes it to your handlers.
  #
  # Example:
  # ```
  # # bot definition...
  #
  # class MyMiddleware < TGBot::Middleware
  #
  #   # All middlware include a reference to the parent bot.
  #   # @bot : Tourmaline::Bot::Client
  #   # getter bot : Tourmaline::Bot::Client
  #
  #   def call(update : Update)
  #     if message = update.message
  #       if user = message.from_user
  #         if text = message.text
  #           puts "#{user.first_name}: #{text}"
  #         end
  #       end
  #     end
  #   end
  # end
  #
  # # Register the middleware with your bot
  # bot.use MyMiddleware
  # ```
  abstract class Middleware
    getter bot : Tourmaline::Bot::Client

    def initialize(@bot : Tourmaline::Bot::Client)
    end

    abstract def call(update : Update)
  end
end

require "./middleware/*"
