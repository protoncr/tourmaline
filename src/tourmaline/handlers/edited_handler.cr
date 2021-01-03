module Tourmaline
  # TODO: Comments
  annotation Edited; end

  class EditedHandler < EventHandler
    def initialize(group = :default, &block : Context ->)
      super(group)
      @proc = block
    end

    def call(client : Client, update : Update)
      if message = update.edited_message || update.edited_channel_post
        context = Context.new(update, message)
        @proc.call(context)
        return true
      end
    end

    def self.annotate(client)
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}

            # Handle `Hears` annotation
            {% for ann in method.annotations(Edited) %}
              %group = {{ ann[:group] || :default }}

              %handler = EditedHandler.new(%group, &->(c : Context) { client.{{ method.name.id }}(c); nil })
              client.add_event_handler(%handler)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    record Context, update : Update, message : Message
  end
end
