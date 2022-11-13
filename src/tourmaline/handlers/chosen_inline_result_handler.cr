module Tourmaline
  module Handlers
    class ChosenInlineResultHandler < EventHandler
      ANNOTATION = OnChosenInlineResult

      property pattern : Regex?

      def initialize(pattern : (String | Regex)? = nil, &block : Context ->)
        super()
        @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
        @proc = block
      end

      def call(update : Update)
        if result = update.chosen_inline_result
          query = result.query
          if query && (pattern = @pattern)
            match = query.match(pattern)
          end
          context = Context.new(update, update.context, result, match)
          @proc.call(context)
        end
      end

      record Context,
        update : Update,
        context : Middleware::Context,
        result : ChosenInlineResult,
        match : Regex::MatchData?
    end
  end
end
