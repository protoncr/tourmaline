module Tourmaline
  module EventRegistry
    getter on_handlers = {} of UpdateAction => Array(Proc(Tourmaline::EventContext, Nil))
    getter action_handlers = {} of String => Array(Proc(Tourmaline::ActionContext, Nil))

    private def register_event_listeners
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(On) || method.annotation(Tourmaline::On)) %}
              %proc = ->(ctx : Tourmaline::EventContext){ {{method.name.id}}(ctx); nil }
              on({{ann[0]}}, %proc)
            {% end %}

            {% if ann = (method.annotation(Action) || method.annotation(Tourmaline::Action)) %}
              %proc = ->(ctx : Tourmaline::ActionContext) { {{method.name.id}}(ctx); nil }
              action({{ann[0]}}, %proc)
            {% end %}
          {% end %}
        {% end %}

        { on: @on_handlers, action: @action_handlers }
      {% end %}
    end

    def on(action : UpdateAction, proc : Tourmaline::EventContext ->)
      @on_handlers[action] ||= [] of Proc(Tourmaline::EventContext, Nil)
      @on_handlers[action] << proc
    end

    def on(action : UpdateAction, &block : Tourmaline::EventContext ->)
      on(action, block)
    end

    def action(action : String | Symbol | Array(String | Symbol), proc : Tourmaline::ActionContext ->)
      if action.is_a?(Array)
        action.each { |a| action(a) }
      else
        @action_handlers[action.to_s] ||= [] of Proc(Tourmaline::ActionContext, Nil)
        @action_handlers[action.to_s] << proc
      end
    end

    def action(action : String | Symbol | Array(String | Symbol), &block : Tourmaline::ActionContext ->)
      action(action, block)
    end

    # Triggers an update event.
    protected def trigger_on_event(event : UpdateAction, update : Update)
      if procs = @on_handlers[event]?
        ctx = Tourmaline::EventContext.new(self, update, update.message, event)
        procs.each do |proc|
          spawn proc.call(ctx)
        end
      end
    end

    protected def trigger_action_event(event : String, update : Update)
      if (procs = @action_handlers[event]?) &&
         (query = update.callback_query) &&
         (message = query.message)
        ctx = Tourmaline::ActionContext.new(self, update, message, query, event)
        procs.each do |proc|
          spawn proc.call(ctx)
        end
      end
    end
  end
end
