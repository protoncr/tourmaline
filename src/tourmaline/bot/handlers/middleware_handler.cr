require "../models"

module Tourmaline::Bot
  # Allows the creation of `Middleware` for your bot.
  module MiddlewareHandler
    macro included
      @middlewares = {} of String => Middleware
    end

    # Attach a `Middleware` to your bot.
    def use(middleware)
      if @middlewares.has_key?(middleware.name)
        raise "A middleware already exists with the name #{middleware.name}"
      end

      @middlewares[middleware.name] = middleware.new(self)
    end

    protected def trigger_all_middlewares(update : Model::Update)
      @middlewares.keys.each { |k| @middlewares[k].call(update) }
    end
  end
end
