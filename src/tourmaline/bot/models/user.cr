require "json"

module Tourmaline::Bot::Model
  # # This object represents a Telegram user or bot.
  class User
    def inline_mention
      name = [first_name, last_name].reject(&.to_s.empty?).join(" ")
      "[#{name}](tg://user?id=#{id})"
    end

    FIELDS = {
      # # Unique identifier for this user or bot
      id: Int64,

      # # True, if this user is a bot
      is_bot: Bool,

      # # User‘s or bot’s first name
      first_name: String,

      # # Optional. User‘s or bot’s last name
      last_name: String?,

      # # Optional. User‘s or bot’s username
      username: String?,

      # # Optional. IETF language tag of the user's language
      language_code: String?
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
