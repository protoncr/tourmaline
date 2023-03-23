module Tourmaline
  class HearsHandler < EventHandler
    getter actions : Array(UpdateAction) = [UpdateAction::Text]

    getter pattern : Regex

    def initialize(pattern : String | Regex, @proc : EventHandlerProc)
      super()
      @pattern = pattern.is_a?(Regex) ? pattern : Regex.new(Regex.escape(pattern))
    end

    def self.new(pattern : String | Regex, &block : EventHandlerProc)
      new(pattern, block)
    end

    def call(ctx : Context)
      if text = ctx.text(strip_command: false)
        if match = text.match(@pattern)
          @proc.call(ctx)
        end
      end
    end
  end
end
