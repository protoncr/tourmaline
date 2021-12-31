module Tourmaline
  class EventMiddleware
    include Middleware

    def call(client : Client, update : Update)
      called = client.event_handlers.each do |handler|
        if handler.call(client, update)
          client.persistence.handle_update(update)
          pp! handler
          break true
        end
      end

      pp! called
      self.next unless called
    end
  end
end
