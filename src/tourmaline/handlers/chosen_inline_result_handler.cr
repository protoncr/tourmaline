module Tourmaline
  module Handlers
    class ChosenInlineResultHandler < EventHandler
      ANNOTATION = OnChosenInlineResult
      getter pattern : Regex?

      def initialize(pattern : (String | Regex)? = nil, group = :default, priority = 0, &block : Context ->)
        super(Context, group, priority, &block)
        @pattern = pattern.is_a?(Regex | Nil) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
        @proc = block
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

      record Context, update : Update, result : ChosenInlineResult, match : Regex::MatchData?
    end
  end
end
