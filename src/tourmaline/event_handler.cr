module Tourmaline
  # Base class for all handlers.
  abstract class EventHandler
    property! client : Client

    abstract def call(update : Update)

    # :nodoc:
    module Annotator
      macro register_event_handler_annotations
        {% begin %}\
          {% for method in @type.methods %}\
            {% for event_handler in Tourmaline::EventHandler.all_subclasses %}\
              {% if event_handler.has_constant?("ANNOTATION") %}\
                {% for ann in method.annotations(event_handler.constant("ANNOTATION").resolve) %}\
                    %handler = {{ event_handler.id }}.new(
                      {% unless ann.args.empty? %}*{{ ann.args }}, {% end %}
                      {% unless ann.named_args.empty? %}**{{ ann.named_args }}, {% end %}
                      &->(ctx : {{ event_handler.id }}::Context) { {{ method.name.id }}(ctx); nil }
                    )
                    %handler.client = self

                    @event_handlers << %handler
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
