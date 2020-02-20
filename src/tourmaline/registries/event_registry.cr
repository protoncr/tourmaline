module Tourmaline
  module EventRegistry
    getter on_handlers = {} of UpdateAction => Array(Proc(Tourmaline::EventContext, Nil))
    getter callback_query_handlers = {} of String => Array(Proc(Tourmaline::CallbackQueryContext, Nil))

    private def register_event_listeners
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(On) || method.annotation(Tourmaline::On)) %}
              %proc = ->(ctx : Tourmaline::EventContext){ {{method.name.id}}(ctx); nil }
              on({{ann[0]}}, %proc)
            {% end %}

            {% if ann = (method.annotation(Query) || method.annotation(Tourmaline::Query)) %}
              %proc = ->(ctx : Tourmaline::CallbackQueryContext) { {{method.name.id}}(ctx); nil }
              on_callback_query({{ann[0]}}, %proc)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    def on(action : UpdateAction, proc : Tourmaline::EventContext ->)
      @on_handlers[action] ||= [] of Proc(Tourmaline::EventContext, Nil)
      @on_handlers[action] << proc
    end

    def on(action : UpdateAction, &block : Tourmaline::EventContext ->)
      on(action, block)
    end

    def on_callback_query(callback_query : String | Symbol | Array(String | Symbol), proc : Tourmaline::CallbackQueryContext ->)
      if callback_query.is_a?(Array)
        callback_query.each { |a| on_callback_query(a) }
      else
        @callback_query_handlers[callback_query.to_s] ||= [] of Proc(Tourmaline::CallbackQueryContext, Nil)
        @callback_query_handlers[callback_query.to_s] << proc
      end
    end

    def on_callback_query(callback_query : String | Symbol | Array(String | Symbol), &block : Tourmaline::CallbackQueryContext ->)
      on_callback_query(callback_query, block)
    end

    # Triggers an update event.
    protected def trigger_event(event : UpdateAction, update : Update)
      case event
      when UpdateAction::CallbackQuery
        trigger_callback_query_event(update)
      else
        if procs = @on_handlers[event]?
          ctx = Tourmaline::EventContext.new(self, update, update.message, event)
          procs.each do |proc|
            spawn do
              proc.call(ctx)
            end
          end
        end
      end
    end

    protected def trigger_callback_query_event(update : Update)
      if (query = update.callback_query) &&
           (message = query.message) &&
             (data = query.data)
        ctx = Tourmaline::CallbackQueryContext.new(self, update, message, query, data)
        if procs = @callback_query_handlers[data]
          procs.each do |proc|
            spawn do
              proc.call(ctx)
            end
          end
        end
      end
    end
  end
end
