module Tourmaline
  module Handlers
    class EditedHandler < EventHandler
      def initialize(group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @proc = block
      end

      def call(client : Client, update : Update)
        if message = update.edited_message || update.edited_channel_post
          context = Context.new(update, message)
          @proc.call(context)
          return true
        end
      end

      record Context, update : Update, message : Message
    end
  end
end
