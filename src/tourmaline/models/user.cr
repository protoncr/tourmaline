module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  class User
    include JSON::Serializable

    getter id : Int64

    @[JSON::Field(key: "is_bot")]
    getter? bot : Bool

    getter first_name : String

    getter last_name : String?

    getter username : String?

    getter language_code : String?

    @[JSON::Field(key: "is_premium")]
    getter? premium : Bool?

    getter? added_to_attachment_menu : Bool?

    getter? can_join_groups : Bool?

    getter? can_read_all_group_messages : Bool?

    getter? supports_inline_queries : Bool?

    # USER API ONLY
    @[JSON::Field(key: "is_verified")]
    getter? verified : Bool?

    # USER API ONLY
    @[JSON::Field(key: "is_scam")]
    getter? scam : Bool?

    def initialize(@id : Int64, @bot : Bool, @first_name : String, @last_name : String? = nil, @language_code : String? = nil, @can_join_groups : Bool? = nil, @can_read_all_group_messages : Bool? = nil, @supports_inline_queries : Bool? = nil)
    end

    def full_name
      [first_name, last_name].compact.join(" ")
    end

    def inline_mention
      name = full_name
      name = name.strip.empty? ? id : name
      "[#{Helpers.escape_md(name)}](tg://user?id=#{id})"
    end
  end
end
