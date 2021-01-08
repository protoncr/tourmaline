module Tourmaline
  module Handlers
    class CallbackQueryHandler < EventHandler
      getter pattern : Regex?

      def initialize(pattern : (String | Regex)? = nil, group = :default, &block : Context ->)
        super(group)
        @proc = block
        @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
      end

      def call(client : Client, update : Update)
        if query = update.callback_query
          data = query.data
          if data && (pattern = @pattern)
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

              # Handle `OnCallbackQuery` annotation
              {% for ann in method.annotations(OnCallbackQuery) %}
                %pattern = {{ ann[:pattern] || ann[0] }}
                %group = {{ ann[:group] || :default }}

                %handler = CallbackQueryHandler.new(%pattern, %group, &->(c : Context) { client.{{ method.name.id }}(c); nil })
                client.add_event_handler(%handler)
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end

      record Context, update : Update, query : CallbackQuery, match : Regex::MatchData?
    end
  end
end
