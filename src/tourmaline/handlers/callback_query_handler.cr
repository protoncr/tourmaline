module Tourmaline
  module Handlers
    class CallbackQueryHandler < EventHandler
      ANNOTATION = OnCallbackQuery

      property pattern : Regex

      def initialize(pattern : String | Regex, &block : Context ->)
        super()
        @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
        @proc = block
      end

      def call(update : Update)
        if query = update.callback_query
          data = query.data || query.game_short_name
          if data
            if match = data.match(@pattern)
              context = Context.new(update, update.context, query.message, query, match)
              @proc.call(context)
            end
          end
        end
      end

      record Context,
        update : Update,
        context : Middleware::Context,
        message : Message?,
        query : CallbackQuery,
        match : Regex::MatchData
    end
  end
end
