module Tourmaline
  module Handlers
    class HearsHandler < EventHandler
      ANNOTATION = Hears

      getter pattern : Regex

      def initialize(pattern : String | Regex, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @pattern = pattern.is_a?(Regex) ? pattern : Regex.new("#{Regex.escape(pattern)}")
        @proc = block
      end

      def call(client : Client, update : Update)
        if message = update.message || update.channel_post
          if (text = message.text) || (text = message.caption)
            if match = text.match(@pattern)
              context = Context.new(update, update.context, message, text, match)
              @proc.call(context)
            end
          end
        end
      end

      record Context,
        update : Update,
        context : Middleware::Context,
        message : Message,
        text : String,
        match : Regex::MatchData
    end
  end
end
