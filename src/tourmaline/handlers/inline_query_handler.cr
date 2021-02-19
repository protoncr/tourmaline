module Tourmaline
  module Handlers
    class InlineQueryHandler < EventHandler
      ANNOTATION = OnInlineQuery

      getter pattern : Regex

      def initialize(pattern : String | Regex, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @proc = block
        @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
      end

      def call(client : Client, update : Update)
        if query = update.inline_query
          data = query.query
          if data
            if match = data.match(@pattern)
              context = Context.new(update, update.context, query, match)
              @proc.call(context)
              return true
            end
          end
        end
      end

      record Context,
        update : Update,
        context : Middleware::Context,
        query : InlineQuery,
        match : Regex::MatchData
    end
  end
end
