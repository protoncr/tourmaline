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
  end

  record MessageEntity, type : String, offset : Int64, length : Int64, url : String?, user : User? do
    include JSON::Serializable
  end
end
