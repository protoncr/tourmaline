require "json"

module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  class Chat
    include JSON::Serializable

    getter id : Int64

    getter type : String

    getter title : String?

    getter username : String?

    getter first_name : String?

    getter last_name : String?

    getter chat_photo : ChatPhoto?

    getter description : String?

    getter invite_link : String?

    getter pinned_message : Message?

    getter permissions : ChatPermissions?

    getter sticker_set_name : String?

    getter can_set_sticker_set : Bool?
  end
end
