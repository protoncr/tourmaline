require "json"

module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  class Message
    include JSON::Serializable

    getter message_id : Int64

    getter from : User?

    @[JSON::Field(converter: Time::EpochMillisConverter)]
    getter date : Time

    getter chat : Chat

    getter forward_from : User?

    getter forward_from_chat : Chat?

    getter forward_from_message_id : Int64?

    getter forward_signature : String?

    @[JSON::Field(converter: Time::EpochMillisConverter)]
    getter forward_date : Time?

    @[JSON::Field(converter: Time::EpochMillisConverter)]
    getter edit_date : Time?

    getter reply_to_message : Message?

    getter media_group_id : String?

    getter author_signature : String?

    getter text : String?

    getter entities : Array(MessageEntity)?

    getter caption_entities : Array(MessageEntity)?

    getter audio : Audio?

    getter document : Document?

    getter game : Game?

    getter photo : Array(PhotoSize)?

    getter sticker : Sticker?

    getter video : Video?

    getter voice : Voice?

    getter video_note : VideoNote?

    getter caption : String?

    getter contact : Contact?

    getter location : Location?

    getter venue : Venue?

    getter new_chat_members : Array(User)?

    getter left_chat_member : User?

    getter new_chat_title : String?

    getter new_chat_photo : Array(PhotoSize)?

    getter delete_chat_photo : Bool?

    getter group_chat_created : Bool?

    getter supergroup_chat_created : Bool?

    getter channel_chat_created : Bool?

    getter migrate_to_chat_id : Int64?

    getter migrate_from_chat_id : Int64?

    getter invoice : Invoice?

    getter successful_payment : SuccessfulPayment?

    def link(chat)
      "https://t.me/{}/{}" % [chat.username, message_id]
    end

    # Delete the message. See `Tourmaline::Bot#delete_message`.
    def delete
      BotContainer.bot.delete_message(chat.id, message_id)
    end

    # Edits the message's caption. See `Tourmaline::Bot#edit_message_caption`
    def edit_caption(caption, **kwargs)
      BotContainer.bot.edit_message_caption(chat.id, caption, **kwargs, message_id: message_id)
    end

    # Set the reply markup for the message. See `Tourmaline::Bot#edit_message_reply_markup`.
    def edit_reply_markup(reply_markup)
      BotContainer.bot.edit_message_reply_markup(chat.id, message_id: message_id, reply_markup: reply_markup)
    end

    # Edits the text of a message. See `Tourmaline::Bot#edit_message_text`.
    def edit_text(text, **kwargs)
      BotContainer.bot.edit_message_text(chat.id, text, **kwargs, message_id: message_id)
    end

    # Forward the message to another chat. See `Tourmaline::Bot#forward_message`.
    def forward(to_chat, **kwargs)
      BotContainer.bot.forward_message(to_chat, chat.id, message_id, **kwargs)
    end

    # Pin the message. See `Tourmaline::Bot#pin_message`.
    def pin(**kwargs)
      BotContainer.bot.pin_message(chat.id, message_id, **kwargs)
    end

    # Reply to a message. See `Tourmaline::Bot#send_message`.
    def reply(message, **kwargs)
      BotContainer.bot.send_message(chat.id, message, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_audio(audio, **kwargs)
      BotContainer.bot.send_audio(chat.id, audio, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_animation(animation, **kwargs)
      BotContainer.bot.send_animation(chat.id, animation, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_contact(phone_number, first_name, **kwargs)
      BotContainer.bot.send_contact(chat.id, phone_number, first_name, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_document(document, **kwargs)
      BotContainer.bot.send_document(chat.id, document, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_location(latitude, longitude, **kwargs)
      BotContainer.bot.send_location(chat.id, latitude, longitude, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_photo(photo, **kwargs)
      BotContainer.bot.send_photo(chat.id, photo, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_media_group(media, **kwargs)
      BotContainer.bot.send_media_group(chat.id, media, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_venue(latitude, longitude, title, address, **kwargs)
      BotContainer.bot.send_venu(chat.id, latitude, longitude, title, address, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_video(video, **kwargs)
      BotContainer.bot.send_video(chat.id, video, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_video_note(video_note, **kwargs)
      BotContainer.bot.send_video(chat.id, video_note, **kwargs, reply_to_message_id: message_id)
    end

    def reply_with_voice(voice, **kwargs)
      BotContainer.bot.send_voice(chat.id, voice, **kwargs, reply_to_message_id: message_id)
    end

    def edit_live_location(latitude, longitude, **kwargs)
      BotContainer.bot.edit_message_live_location(chat.id, latitude, longitude, **kwargs, message_id: message_id)
    end

    def stop_live_location(**kwargs)
      BotContainer.bot.stop_message_live_location(chat.id, message_id, **kwargs)
    end
  end

  record MessageEntity, type : String, offset : Int64, length : Int64, url : String?, user : User? do
    include JSON::Serializable
  end
end
