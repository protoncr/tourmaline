require "../types"

module Tourmaline::Bot
  module MiddlewareHandler
    macro included
      @middlewares = {} of String => Middleware
    end

    def use(middleware)
      if @middlewares.has_key?(middleware.name)
        raise "A middleware already exists with the name #{middleware.name}"
      end

      @middlewares[middleware.name] = middleware.new(self)
    end

    def trigger_all_middlewares(update : Update)
      @middlewares.keys.each { |k| @middlewares[k].call(update) }
    end
  end
end
