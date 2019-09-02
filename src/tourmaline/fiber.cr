require "http/server"

# :nodoc:
class Fiber
  property telegram_bot_server_http_context : HTTP::Server::Context?
end
