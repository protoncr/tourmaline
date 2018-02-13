require "./types"

module Tourmaline::Bot
  module MiddlewareHandler

    macro included
      @middlewares = [] of Update ->
    end

    def use(middleware : Update ->)
      @middlewares.push middleware
    end

    def use(&block : Update ->)
      @middlewares.push block
    end

    def trigger_all_middlewares(update : Update)
      @middlewares.each { |m| m.call(update) }
    end

  end
end
