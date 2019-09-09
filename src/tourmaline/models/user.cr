require "json"

module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  class User
    include JSON::Serializable

    getter id : Int64

    getter is_bot : Bool

    getter first_name : String

    getter last_name : String?

    getter username : String?

    getter language_code : String?

    def full_name
      [first_name, last_name].compact.join(" ")
    end

    def inline_mention
      "[#{full_name}](tg://user?id=#{id})"
    end

    def profile_photos(offset = nil, limit = nil)
      BotContainer.bot.get_user_profile_photos(id, offset, limit)
    end
  end
end
