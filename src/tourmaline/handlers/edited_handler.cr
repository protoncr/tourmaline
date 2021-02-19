module Tourmaline
  module Handlers
    class EditedHandler < EventHandler
      ANNOTATION = Edited

      def initialize(group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @proc = block
      end

      def call(client : Client, update : Update)
        if message = update.edited_message || update.edited_channel_post
          context = Context.new(update, update.context, message)
          @proc.call(context)
          return true
        end
      end

      record Context, update : Update, context : Middleware::Context, message : Message
    end
  end
end
