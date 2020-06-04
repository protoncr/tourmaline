module Tourmaline
  # Processes updates. `Update`s first get checked to see if they fit
  # into the given `UpdateAction` and then checked against the provided
  # Filter`s (if any).
  class EventHandler

    getter action : UpdateAction
    getter filter : (Filter | FilterGroup)?
    getter group  : String
    getter async  : Bool

    def initialize(@action : UpdateAction, filter = nil, group = :default, async = true, &block : Client, Update ->)
      @proc = block
      @filter = filter
      @group = group.to_s.downcase
      @async = async
    end

    def handle_update(client : Client, update : Update)
      actions = UpdateAction.from_update(update)
      if actions.includes?(@action)
        if filter = @filter
          return unless filter.exec(client, update)
        end

        if @async
          spawn @proc.call(client, update)
        else
          @proc.call(client, update)
        end

        true
      end
    end

    # :nodoc:
    module Annotator
      private def register_event_handlers
        {% begin %}
          {% for command_class in Tourmaline::Client.subclasses %}
            {% for method in command_class.methods %}

              # Handle `On` annotation
              {% for ann in method.annotations(On) %}
                %action = {{ ann[:action] || ann[0] }}
                %filter = {{ ann[:filter] || ann[1] }}
                %group = {{ ann[:group] || :default }}
                %async = {{ ann[:async].nil? ? true : !!ann[:async] }}

                if %action.is_a?(Symbol | String)
                  begin
                    %action = UpdateAction.parse(%action.to_s)
                  rescue
                    raise "Unknown UpdateAction #{%action}"
                  end
                end

                %handler = EventHandler.new(%action, %filter, %group, %async, &->(c : Client, u : Update) { {{ method.name.id }}(c, u) })
                add_event_handler(%handler)
              {% end %}

              # Handle `Command` annotation
              {% for ann in method.annotations(Command) %}
                %group  = {{ ann.named_args[:group] || :default }}
                %cmd_filter = CommandFilter.new(
                  {{ ann.named_args[:command] || ann.named_args[:commands] || ann.args[0] }},
                  {{ ann.named_args[:prefix] }},
                  {{ ann.named_args[:private_only] || false }},
                  {{ ann.named_args[:group_only] || false }},
                  {{ ann.named_args[:admin_only] || false }}
                )
                %filter = {% if ann.named_args[:filter] %} %cmd_filter & {{ ann.named_args[:filter] }} {% else %} %cmd_filter {% end %}
                %async = {{ ann[:async].nil? ? true : !!ann[:async] }}
                %handler = EventHandler.new(:text, %filter, %group, %async, &->(c : Client, u : Update) { {{ method.name.id }}(c, u) })
                add_event_handler(%handler)
              {% end %}

              # Handle `OnCallbackQuery` annotation
              {% for ann in method.annotations(OnCallbackQuery) %}
                %pattern = {{ ann[:pattern] || ann[0] }}
                %group  = {{ ann.named_args[:group] || :default }}
                %cq_filter = CallbackQueryFilter.new(%pattern)
                %async = {{ ann[:async].nil? ? true : !!ann[:async] }}
                %filter = {% if ann.named_args[:filter] %} %cq_filter & {{ ann.named_args[:filter] }} {% else %} %cq_filter {% end %}
                %handler = EventHandler.new(:callback_query, %filter, %group, %async, &->(c : Client, u : Update) { {{ method.name.id }}(c, u) })
                add_event_handler(%handler)
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end
