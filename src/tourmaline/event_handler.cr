module Tourmaline
  # Base class for all handlers.
  abstract class EventHandler
    abstract def call(update : Update)

    # :nodoc:
    module Annotator
      macro register_event_handler_annotations(client)
        {% begin %}\
          {% for method in @type.methods %}\
            {% for event_handler in Tourmaline::EventHandler.all_subclasses %}\
              {% if event_handler.has_constant?("ANNOTATION") %}\
                {% for ann in method.annotations(event_handler.constant("ANNOTATION").resolve) %}\
                    @event_handlers << {{ event_handler.id }}.new(
                      {{ client.id }},
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
