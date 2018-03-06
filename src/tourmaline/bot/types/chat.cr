require "json"

module Tourmaline::Bot
  # # This object represents a Telegram user or bot.
  class Chat
    JSON.mapping(

      id: Int64,

      type: String,

      title: String?,

      username: String?,

      first_name: String?,

      last_name: String?,

      all_members_are_administrators: Bool?,

      chat_photo: ChatPhoto?,

      description: String?,

      invite_link: String?,

      pinned_message: Message?,

      sticker_set_name: String?,

      can_set_sticker_set: Bool?
    )
  end
end
