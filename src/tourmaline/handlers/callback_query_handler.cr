module Tourmaline
  module Handlers
    class CallbackQueryHandler < EventHandler
      ANNOTATION = OnCallbackQuery
      getter pattern : Regex

      def initialize(pattern : String | Regex, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
        @proc = block
      end

      def call(client : Client, update : Update)
        if query = update.callback_query
          data = query.data || query.game_short_name
          if data
            if match = data.match(@pattern)
              context = Context.new(update, query.message, query, match)
              @proc.call(context)
              return true
            end
          end
        end
      end

      record Context, update : Update, message : Message?, query : CallbackQuery, match : Regex::MatchData
    end
  end
end
