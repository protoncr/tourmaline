module Tourmaline
  # TODO: Comments
  annotation OnInlineQuery; end

  class InlineQueryHandler < EventHandler
    getter pattern : Regex?

    def initialize(pattern : (String | Regex)? = nil, group = :default, &block : Context ->)
      super(group)
      @proc = block
      @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
    end

    def call(client : Client, update : Update)
      if query = update.inline_query
        data = query.query.to_s
        if pattern = @pattern
          match = data.match(pattern)
        end
        context = Context.new(update, query, match)
        @proc.call(context)
        return true
      end
    end

    def self.annotate(client)
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}

            # Handle `OnInlineQuery` annotation
            {% for ann in method.annotations(OnInlineQuery) %}
              %pattern = {{ ann[:pattern] || ann[0] }}
              %group = {{ ann[:group] || :default }}

              %handler = InlineQueryHandler.new(%pattern, %group, &->(c : Context) { client.{{ method.name.id }}(c); nil })
              client.add_event_handler(%handler)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    record Context, update : Update, query : InlineQuery, match : Regex::MatchData?
  end
end
