module Tourmaline
  struct Context
    getter client : Client
    getter update : Update

    def initialize(@client : Client, @update : Update)
    end

    # Pass all update methods to the update object
    delegate :message, :message?, :edited_message, :edited_message?, :channel_post, :channel_post?,
      :edited_channel_post, :edited_channel_post?, :inline_query, :inline_query?, :chosen_inline_result,
      :chosen_inline_result?, :callback_query, :callback_query?, :shipping_query, :shipping_query?,
      :pre_checkout_query, :pre_checkout_query?, :poll, :poll?, :poll_answer, :poll_answer?, to: @update

    # Get the message text, without the command
    def text
      if message = @update.message
        entity, _ = message.text_entities("bot_command").first
        message.text.to_s[entity.offset + entity.length..-1].lstrip
      end
    end

    # Respond to the incoming message
    def respond(text : String, **args)
      @client.send_message(@update.message.chat.id, text, **args)
    end

    # Reply directly to the incoming message
    def reply(text : String, **args)
      if message = @update.message
        args = args.merge(reply_to_message: message.message_id)
        @client.send_message(message.chat.id, text, **args)
      end
    end
  end
end
