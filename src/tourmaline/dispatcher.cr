module Tourmaline
  # The Dispatcher is responsible for dispatching requests to the appropria
  class Dispatcher
    getter middleware : Array(Middleware)
    getter event_handlers : Hash(UpdateAction, Array(EventHandlerType))

    def initialize(@client : Client)
      @middleware = [] of Middleware
      @event_handlers = {} of UpdateAction => Array(EventHandlerType)
    end

    def process(update : Update)
      actions = UpdateAction.from_update(update)
      context = Context.new(@client, update)

      @middleware.each do |middleware|
        begin
          middleware.call_internal(context)
        rescue stop : Middleware::Stop
          return
        end
      end

      actions.each do |action|
        if handlers = @event_handlers[action]?
          handlers.each do |handler|
            handler.call(context)
          end
        end
      end
    end

    def on(*actions : UpdateAction, &block : Context ->)
      actions.each do |action|
        @event_handlers[action] ||= [] of EventHandlerType
        @event_handlers[action] << block
      end
    end

    def register(handler : EventHandler)
      handler.actions.each do |action|
        @event_handlers[action] ||= [] of EventHandlerType
        @event_handlers[action] << handler
      end
    end

    def use(*middlewares : Middleware)
      middlewares.each do |middleware|
        @middleware << middleware
      end
    end

    def use(*middlewares : Middleware.class)
      middlewares.each do |middleware|
        @middleware << middleware.new
      end
    end
  end
end
