module Tourmaline
  # Base class for all handlers.
  abstract class EventHandler

    getter group : String

    getter priority : Int32

    def initialize(group = :default, priority = 0)
      @group = group.to_s
      @priority = priority.to_i
    end

    abstract def call(client : Client, update : Update)

    # :nodoc:
    module Annotator
      macro register_event_handler_annotations
        {% begin %}\
          {% for method in @type.methods %}\
            {% for event_handler in Tourmaline::EventHandler.subclasses %}\
              {% if event_handler.has_constant?("ANNOTATION") %}\
                {% for ann in method.annotations(event_handler.constant("ANNOTATION").resolve) %}\
                    @event_handlers << {{ event_handler.id }}.new(
                      {% unless ann.args.empty? %}*{{ ann.args }}, {% end %}
                      {% unless ann.named_args.empty? %}**{{ ann.named_args }}, {% end %}
                      &->(ctx : {{ event_handler.id }}::Context) { {{ method.name.id }}(ctx); nil }
                    )
                {% end %}\
              {% end %}\
            {% end %}\
          {% end %}\
        {% end %}\
      end
    end
  end
end

require "./handlers/*"
