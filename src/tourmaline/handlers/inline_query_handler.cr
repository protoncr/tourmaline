module Tourmaline
  module Handlers
    class InlineQueryHandler < EventHandler
      getter pattern : Regex?

      def initialize(pattern : (String | Regex)? = nil, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
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

      record Context, update : Update, query : InlineQuery, match : Regex::MatchData?
    end
  end
end
