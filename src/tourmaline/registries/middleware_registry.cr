# require "../middleware"

# module Tourmaline
#   module MiddlewareRegistry
#     getter middleware = [] of Middleware

#     # Attach a `Middleware` to your bot.
#     macro use(middleware)
#       {% begin %}
#         %mw = {{ middleware }}.new
#         @middleware << %mw
#         %mw.init(self)
#       {% end %}
#     end

#     protected def trigger_all_middleware(update : Update)
#       context = Middleware::Context.new(self, update)
#       @middleware.each { |m| m.call(context) }
#     end
#   end
# end
