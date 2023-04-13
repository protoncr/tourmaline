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
        @client.send_message(**kwargs, chat_id: message.chat.id, text: text)
      end
    end

    # Reply directly to the incoming message
    def reply(text : String, **kwargs)
      with_message do |message|
        kwargs = kwargs.merge(reply_to_message_id: message.message_id)
        @client.send_message(**kwargs, chat_id: message.chat.id, text: text)
      end
    end

    # {% for content_type in %w(audio animation contact document sticker photo media_group venu video video_note voice invoice poll) %}
    {% for key, value in {"audio" => "audio", "animation" => "animation", "contact" => "contact", "document" => "document", "sticker" => "sticker", "photo" => "photo", "media_group" => "media", "venue" => "venue", "video" => "video", "video_note" => "video_note", "voice" => "voice", "invoice" => "invoice"} %}
      # Respond with a {{key.id}}
      def respond_with_{{key.id}}({{ key.id }}, **kwargs)
        with_message do |message|
          @client.send_{{ key.id }}(**kwargs, {{ value.id }}: {{ key.id }}, chat_id: message.chat.id)
        end
      end

      # Reply directly to the incoming message with a {{key.id}}
      def reply_with_{{key.id}}({{ key.id }}, **kwargs)
        with_message do |message|
          kwargs = kwargs.merge(reply_to_message_id: message.message_id)
          @client.send_{{ key.id }}(**kwargs, {{ value.id }}: {{ key.id }}, chat_id: message.chat.id)
        end
      end
    {% end %}

    {% for name, emoji in {"dice" => "🎲" , "dart" => "🎯" , "basketball" => "🏀" , "football" => "🏈" , "slot_machine" => "🎰", "bowling" => "🎳"} %}
      # Respond with a {{name.id}}
      def respond_with_{{name.id}}(**kwargs)
        with_message do |message|
          @client.send_dice(**kwargs, chat_id: message.chat.id, emoji: {{emoji.stringify}})
        end
      end

      # Reply directly to the incoming message with a {{name.id}}
      def reply_with_{{name.id}}(**kwargs)
        with_message do |message|
          kwargs = kwargs.merge(reply_to_message_id: message.message_id)
          @client.send_dice(**kwargs, chat_id: message.chat.id, emoji: {{emoji.stringify}})
        end
      end
    {% end %}

    # Respond with a location
    def respond_with_location(latitude : Float64, longitude : Float64, **kwargs)
      with_message do |message|
        @client.send_location(**kwargs, latitude: latitude, longitude: longitude, chat_id: message.chat.id)
      end
    end

    # Reply directly to the incoming message with a location
    def reply_with_location(latitude : Float64, longitude : Float64, **kwargs)
      with_message do |message|
        kwargs = kwargs.merge(reply_to_message_id: message.message_id)
        @client.send_location(**kwargs, latitude: latitude, longitude: longitude, chat_id: message.chat.id)
      end
    end

    # Respond with a poll
    def respond_with_poll(question : String, options : Array(String), **kwargs)
      with_message do |message|
        @client.send_poll(**kwargs, question: question, options: options, chat_id: message.chat.id)
      end
    end

    # Reply directly to the incoming message with a poll
    def reply_with_poll(question : String, options : Array(String), **kwargs)
      with_message do |message|
        kwargs = kwargs.merge(reply_to_message_id: message.message_id)
        @client.send_poll(**kwargs, question: question, options: options, chat_id: message.chat.id)
      end
    end

    # Context aware message deletion
    def delete_message(message_id : Int32)
      with_message do |message|
        @client.delete_message(chat_id: message.chat.id, message_id: message_id)
      end
    end

    # Context aware forward
    def forward_message(to_chat, **kwargs)
      with_message do |message|
        @client.forward_message(**kwargs, chat_id: to_chat, from_chat_id: message.chat.id, message_id: message.id)
      end
    end

    # Context aware pinning
    def pin_message(**kwargs)
      with_message do |message|
        @client.pin_chat_message(**kwargs, chat_id: message.chat.id, message_id: message.id)
      end
    end

    # Context aware unpinning
    def unpin_message(**kwargs)
      with_message do |message|
        @client.unpin_chat_message(**kwargs, chat_id: message.chat.id)
      end
    end

    # Context aware editing
    def edit_message(text : String, **kwargs)
      with_message do |message|
        @client.edit_message_text(**kwargs, chat_id: message.chat.id, message_id: message.message_id, text: text)
      end
    end

    # Context aware live location editing
    def edit_live_location(latitude : Float64, longitude : Float64, **kwargs)
      with_message do |message|
        @client.edit_message_live_location(**kwargs, chat_id: message.chat.id, message_id: message.message_id, latitude: latitude, longitude: longitude)
      end
    end

    def answer_callback_query(**kwargs)
      if query = @update.callback_query
        @client.answer_callback_query(**kwargs, callback_query_id: query.id)
      end
    end

    def answer_inline_query(**kwargs)
      if query = @update.inline_query
        @client.answer_inline_query(**kwargs, inline_query_id: query.id)
      end
    end

    def answer_shipping_query(**kwargs)
      if query = @update.shipping_query
        @client.answer_shipping_query(**kwargs, shipping_query_id: query.id)
      end
    end

    def answer_pre_checkout_query(**kwargs)
      if query = @update.pre_checkout_query
        @client.answer_pre_checkout_query(**kwargs, pre_checkout_query_id: query.id)
      end
    end

    # Context aware chat actions
    def send_chat_action(action : String | ChatAction)
      with_message do |message|
        @client.send_chat_action(chat_id: message.chat.id, action: action.to_s)
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
