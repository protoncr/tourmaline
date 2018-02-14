module Tourmaline::Bot
  abstract class Middleware

    def initialize(@bot : Client)
    end

    abstract def call(update : Update)

  end
end

require "./middleware/*"
