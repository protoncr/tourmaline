module Tourmaline
  module EventRegistry
    getter event_handlers = {} of UpdateAction => Array(Proc(Update, Nil))

    private def register_event_listeners
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(On) || method.annotation(Tourmaline::On)) %}
              %proc = ->(update : Update){ {{method.name.id}}(update); nil }
              on({{ann[0]}}, %proc)
            {% end %}
          {% end %}
        {% end %}
        @event_handlers
      {% end %}
    end

    def on(action : UpdateAction, proc : Update ->)
      @event_handlers[action] ||= [] of Proc(Update, Nil)
      @event_handlers[action] << proc
    end

    def on(action : UpdateAction, &block : Update ->)
      on(action, block)
    end
  end
end
