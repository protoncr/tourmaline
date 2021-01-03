module Tourmaline
  # TODO: Comments
  annotation OnChosenInlineResult; end

  class ChosenInlineResultHandler < EventHandler
    getter pattern : Regex?

    def initialize(pattern : (String | Regex)? = nil, group = :default, &block : Context ->)
      super(group)
      @proc = block
      @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
    end

    def call(client : Client, update : Update)
      if result = update.chosen_inline_result
        query = result.query
        if query && (pattern = @pattern)
          match = query.match(pattern)
        end
        context = Context.new(update, result, match)
        @proc.call(context)
        return true
      end
    end

    def self.annotate(client)
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}

            # Handle `OnChosenInlineResult` annotation
            {% for ann in method.annotations(OnChosenInlineResult) %}
              %pattern = {{ ann[:pattern] || ann[0] }}
              %group = {{ ann[:group] || :default }}

              %handler = ChosenInlineResultHandler.new(%pattern, %group, &->(c : Context) { client.{{ method.name.id }}(c); nil })
              client.add_event_handler(%handler)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    record Context, update : Update, result : ChosenInlineResult, match : Regex::MatchData?
  end
end
