module Tourmaline
  module Handlers
    class CallbackQueryHandler < EventHandler
      ANNOTATION = OnCallbackQuery
      getter pattern : Regex?

      def initialize(pattern : (String | Regex)? = nil, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
        @proc = block
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

      record Context, update : Update, query : CallbackQuery, match : Regex::MatchData?
    end
  end
end
