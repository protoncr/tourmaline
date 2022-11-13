module Tourmaline
  module Handlers
    class EditedHandler < EventHandler
      ANNOTATION = Edited

      def initialize(&block : Context ->)
        super()
        @proc = block
      end

      def call(update : Update)
        if message = update.edited_message || update.edited_channel_post
          context = Context.new(update, update.context, message)
          @proc.call(context)
        end
      end

      record Context, update : Update, context : Middleware::Context, message : Message
    end
  end
end
