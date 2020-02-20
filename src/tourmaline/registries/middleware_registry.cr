module Tourmaline
  module MiddlewareRegistry
    getter middleware = {} of String => Middleware

    # Attach a `Middleware` to your bot.
    def use(middleware)
      if @middleware.has_key?(middleware.name)
        raise "A middleware already exists with the name #{middleware.name}"
      end

      @middleware[middleware.name] = middleware
    end

    protected def trigger_all_middleware(update : Update)
      @middleware.keys.each { |k| @middleware[k].call(self, update) }
    end
  end
end
