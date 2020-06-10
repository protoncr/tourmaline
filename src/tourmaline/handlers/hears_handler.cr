module Tourmaline
  # TODO: Comments
  annotation Hears; end

  class HearsHandler < EventHandler
    getter pattern : Regex

    def initialize(pattern : String | Regex, group = :default, async = true, &block : Context ->)
      super(group, async)
      @proc = block
      @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("#{Regex.escape(pattern)}")
    end

    def call(client : Client, update : Update)
      if message = update.message
        if (text = message.text) || (text = message.caption)
          if match = text.match(@pattern)
            context = Context.new(update, message, text, match)
            @proc.call(context)
            return true
          end
        end
      end
    end

    def self.annotate(client)
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}

            # Handle `Hears` annotation
            {% for ann in method.annotations(Hears) %}
              %pattern = {{ ann[:pattern] || ann[0] }}
              %group = {{ ann[:group] || :default }}
              %async = {{ !!ann[:async] }}

              %handler = HearsHandler.new(%pattern, %group, %async, &->(c : Context) { client.{{ method.name.id }}(c); nil })
              client.add_event_handler(%handler)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    record Context, update : Update, message : Message, text : String, match : Regex::MatchData
  end
end
