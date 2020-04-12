module Tourmaline
  class EventHandler

    getter action : UpdateAction
    getter filter : (Filter | FilterGroup)?

    def initialize(@action : UpdateAction, @filter = nil, &block : Client, Update ->)
      @proc = block
    end

    def handle_update(client : Client, update : Update)
      actions = Helpers.actions_from_update(update)
      if actions.includes?(@action)
        if filter = @filter
          return unless filter.exec(client, update)
        end
        @proc.call(client, update)
      end
    end

    module Annotator
      private def register_event_handlers
        {% begin %}
          {% for command_class in Tourmaline::Client.subclasses %}
            {% for method in command_class.methods %}

              # Handle `On` annotation
              {% for ann in method.annotations(On) %}
                %action = {{ ann[0] }}
                %filter = {{ ann[:filter] || ann[1] }}

                if %action.is_a?(Symbol | String)
                  begin
                    %action = UpdateAction.parse(%action.to_s)
                  rescue
                    raise "Unknown UpdateAction #{%action}"
                  end
                end

                %handler = EventHandler.new(%action, %filter, &->(c : Client, u : Update) { {{ method.name.id }}(c, u) })
                add_event_handler(%handler)
              {% end %}

              # Handle `Command` annotation
              {% for ann in method.annotations(Command) %}
                %filter = CommandFilter.new(\
                  {% unless ann.args.empty? %}*{{ ann.args }},{% end %}\
                  {% unless ann.named_args.empty? %}**{{ ann.named_args }}{% end %}\
                  )
                %handler = EventHandler.new(:text, %filter, &->(c : Client, u : Update) { {{ method.name.id }}(c, u) })
                add_event_handler(%handler)
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end
