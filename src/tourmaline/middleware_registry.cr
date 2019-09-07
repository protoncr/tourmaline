require "./middleware"

module Tourmaline
  module MiddlewareRegistry
    getter middlewares = {} of String => Middleware

    # Attach a `Middleware` to your bot.
    def use(middleware)
      if @middlewares.has_key?(middleware.name)
        raise "A middleware already exists with the name #{middleware.name}"
      end

      @middlewares[middleware.name] = middleware.new(self)
    end

    protected def trigger_all_middlewares(update : Model::Update)
      @middlewares.keys.each { |k| spawn @middlewares[k].call(update) }
    end
  end
end
