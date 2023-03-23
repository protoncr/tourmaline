module Tourmaline
  # This object represents a Telegram user or bot.
  class Chat
    include JSON::Serializable

    getter id : Int64

    getter type : Type

    getter title : String?

    getter username : String?

    getter first_name : String?

    getter last_name : String?

    @[JSON::Field(key: "is_forum")]
    getter? forum : Bool?

    getter photo : ChatPhoto?

    getter bio : String?

    getter active_usernames : Array(String) = [] of String

    getter emoji_status_custom_emoji_id : String?

    getter? has_private_forwards : Bool?

    getter? has_restricted_voice_and_video_messages : Bool?

    getter join_to_send_messages : Bool?

    getter join_by_request : Bool?

    getter description : String?

    getter invite_link : String?

    getter pinned_message : Message?

    getter permissions : ChatPermissions?

    getter slow_mode_delay : Int32?

    getter message_auto_delete_time : Int32?

    getter? has_aggressive_anti_spam_enabled : Bool?

    getter? has_hidden_members : Bool?

    getter? has_protected_content : Bool?

    getter sticker_set_name : String?

    getter? can_set_sticker_set : Bool?

    getter linked_chat_id : Int64?

    getter location : ChatLocation?

    # USER API ONLY
    @[JSON::Field(key: "is_verified")]
    getter? verified : Bool?

    # USER API ONLY
    @[JSON::Field(key: "is_scam")]
    getter? scam : Bool?

    def name
      if first_name || last_name
        [first_name, last_name].compact.join(" ")
      else
        title.to_s
      end
    end

    def supergroup?
      type == Type::Supergroup
    end

    def private?
      type == Type::Private
    end

    def group?
      type == Type::Group
    end

    def channel?
      type == Type::Channel
    end

    enum Type
      Private
      Group
      Supergroup
      Channel

      def self.new(pull : JSON::PullParser)
        parse(pull.read_string)
      end

      def to_json(json : JSON::Builder)
        json.string(to_s)
      end
    end
  end
end
