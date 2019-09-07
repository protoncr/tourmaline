module Tourmaline
  class LogMiddleware < Middleware
    getter name = "response_logger"

    def call(ctx : Middleware::Context)
      ctx.bot.logger.debug(ctx.update.to_pretty_json)
    end
  end
end
