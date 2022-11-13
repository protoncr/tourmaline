module Tourmaline
  class EventMiddleware
    include Middleware

    def call(client : Client, update : Update)
      return if client.event_handlers.each do |handler|
                  if handler.call(update)
                    client.persistence.handle_update(update)
                    break true
                  end
                end

      self.next
    end
  end
end
