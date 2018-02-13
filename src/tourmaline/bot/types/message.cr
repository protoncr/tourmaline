require "json"

module Tourmaline::Bot

  ## This object represents a Telegram user or bot.
  struct Message

    JSON.mapping(

      message_id: Int64,

      from: User?,

      date: { type: Time, converter: Time::EpochMillisConverter },

      chat: Chat,

      forward_from: User?,

      forward_from_chat: Chat?,

      forward_from_message_id: Int64?,

      forward_signature: String?,

      forward_date: { type: Time, converter: Time::EpochMillisConverter, nilable: true },

      edit_date: { type: Time, converter: Time::EpochMillisConverter, nilable: true },

      media_group_id: String?,

      author_signature: String?,

      text: String?,

      entities: Array(MessageEntity)?,

      caption_entities: Array(MessageEntity)?,

      audio: Audio?,

      document: Document?,

      game: Game?,

      photo: Array(PhotoSize)?,

      sticker: Sticker?,

      video: Video?,

      voice: Voice?,

      video_note: VideoNote?,

      caption: String?,

      contact: Contact?,

      location: Location?,

      venue: Venue?,

      new_chat_members: Array(User)?,

      left_chat_member: User?,

      new_chat_title: String?,

      new_chat_photo: Array(PhotoSize)?,

      delete_chat_photo: Bool?,

      group_chat_created: Bool?,

      supergroup_chat_created: Bool?,

      channel_chat_created: Bool?,

      migrate_to_chat_id: Int64?,

      migrate_from_chat_id: Int64?,

      invoice: Invoice?,

      successful_payment: SuccessfulPayment?,
    )

  end

  class MessageEntity

    JSON.mapping(

      type: String,

      offset: Int64,

      length: Int64,

      url: String?,

      user: User?

    )

  end
end
