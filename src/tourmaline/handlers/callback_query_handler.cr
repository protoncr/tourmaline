module Tourmaline
  class CallbackQueryHandler < EventHandler
    getter actions : Array(UpdateAction) = [UpdateAction::CallbackQuery]

    getter pattern : Regex

    def initialize(pattern : String | Regex, @proc : EventHandlerProc)
      super()
      @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("^#{Regex.escape(pattern)}$")
    end

    def self.new(pattern : String | Regex, &block : EventHandlerProc)
      new(pattern, block)
    end

    def call(ctx : Context)
      if query = ctx.callback_query
        data = query.data || query.game_short_name
        if data
          if match = data.match(@pattern)
            @proc.call(ctx)
          end
        end
      end
    end
  end
end
