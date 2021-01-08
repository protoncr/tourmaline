module Tourmaline
  module Handlers
    class UpdateHandler < EventHandler
      getter action : UpdateAction

      def initialize(@action : UpdateAction, group = :default, &block : Update ->)
        super(group)
        @proc = block
      end

      def call(client : Client, update : Update)
        actions = UpdateAction.from_update(update)
        if actions.includes?(@action)
          @proc.call(update)
          true
        end
      end

      def self.annotate(client)
        {% begin %}
          {% for command_class in Tourmaline::Client.subclasses %}
            {% for method in command_class.methods %}

              # Handle `On` annotation
              {% for ann in method.annotations(On) %}
                %action = {{ ann[:action] || ann[0] }}
                %group = {{ ann[:group] || :default }}

                if %action.is_a?(Symbol | String)
                  begin
                    %action = UpdateAction.parse(%action.to_s)
                  rescue
                    raise "Unknown UpdateAction #{%action}"
                  end
                end

                %handler = UpdateHandler.new(%action, %group, &->(u : Update) { client.{{ method.name.id }}(u); nil })
                client.add_event_handler(%handler)
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end
