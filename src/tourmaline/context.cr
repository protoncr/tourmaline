module Tourmaline
  struct Context
    getter client : Client
    getter update : Update

    def initialize(@client : Client, @update : Update)
    end

    # Slightly shorter alias for the client
    def api
      @client
    end

    # Pass all update methods to the update object
    delegate :message, :message?, :edited_message, :edited_message?, :channel_post, :channel_post?,
      :edited_channel_post, :edited_channel_post?, :inline_query, :inline_query?, :chosen_inline_result,
      :chosen_inline_result?, :callback_query, :callback_query?, :shipping_query, :shipping_query?,
      :pre_checkout_query, :pre_checkout_query?, :poll, :poll?, :poll_answer, :poll_answer?, to: @update

    # Retuns the message, edited_message, channel_post, edited_channel_post, callback_query.message, or nil
    def message
      @update.message || @update.edited_message || @update.channel_post || @update.edited_channel_post || @update.callback_query.try &.message
    end

    # Returns the message, edited_message, channel_post, edited_channel_post, callback_query.message, or raises an exception
    def message!
      message.not_nil!
    end

    # Get the message text, return nil if there is no message
    def text(strip_command = true)
      if strip_command && (message = @update.message)
        entity, _ = message.text_entities("bot_command").first
        message.text.to_s[entity.offset + entity.length..-1].lstrip
      else
        @update.message.try &.text
      end
    end

    # Get the message text, raise an exception if there is no message
    def text!(strip_command = true)
      text(strip_command).not_nil!
    end

    # Get the command name, return nil if there is no message
    def command
      if (message = @update.message)
        entity, _ = message.text_entities("bot_command").first
        message.text.to_s[1, entity.offset + entity.length - 1].strip
      end
    end

    # Get the command name, raise an exception if there is no message
    def command!
      command.not_nil!
    end

    # Respond to the incoming message
    def respond(text : String, **kwargs)
      with_message do |message|
        @client.send_message(message.chat.id, text, **kwargs)
      end
    end

    # Reply directly to the incoming message
    def reply(text : String, **kwargs)
      with_message do |message|
        kwargs = kwargs.merge(reply_to_message_id: message.message_id)
        @client.send_message(message.chat.id, text, **kwargs)
      end
    end

    {% for content_type in %w(audio animation contact document location sticker photo media_group venu video video_note voice invoice poll dice dart basketball) %}
      # Respond with a {{content_type.id}}
      def respond_with_{{content_type.id}}(*args, **kwargs)
        with_message do |message|
          @client.send_{{ content_type.id }}(message.chat.id, *args, **kwargs)
        end
      end

      # Reply directly to the incoming message with a {{content_type.id}}
      def reply_with_{{content_type.id}}(*args, **kwargs)
        with_message do |message|
          kwargs = kwargs.merge(reply_to_message_id: message.message_id)
          @client.send_{{ content_type.id }}(message.chat.id, *args, **kwargs)
        end
      end
    {% end %}

    # Context aware message deletion
    def delete_message(message_id : Int32)
      with_message do |message|
        @client.delete_message(message.chat.id, message_id)
      end
    end

    # Context aware forward
    def forward_message(to_chat, **args)
      with_message do |message|
        @client.forward_message(to_chat, message.chat, message.id, **args)
      end
    end

    # Context aware pinning
    def pin_message(**args)
      with_message do |message|
        @client.pin_chat_message(message.chat.id, message.id, **args)
      end
    end

    # Context aware unpinning
    def unpin_message(**args)
      with_message do |message|
        @client.unpin_chat_message(message.chat.id, **args)
      end
    end

    # Context aware query answer
    def answer_query(*args, **kwargs)
      if query = @update.callback_query
        @client.answer_callback_query(query.id, *args, **kwargs)
      elsif query = @update.inline_query
        @client.answer_inline_query(query.id, *args, **kwargs)
      elsif query = @update.shipping_query
        @client.answer_shipping_query(query.id, *args, **kwargs)
      elsif query = @update.pre_checkout_query
        @client.answer_pre_checkout_query(query.id, *args, **kwargs)
      end
    end

    # Context aware chat actions
    def send_chat_action(action : ChatAction)
      with_message do |message|
        @client.send_chat_action(message.chat.id, action)
      end
    end

    # If the update contains a message, pass it to the block. Less boilerplate.
    def with_message
      if message
        yield message!
      end
    end
  end
end
