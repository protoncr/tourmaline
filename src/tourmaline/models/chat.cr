module Tourmaline
  # This object represents a Telegram user or bot.
  class Chat
    include JSON::Serializable
    include Tourmaline::Model

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

    getter has_private_forwards : Bool?

    getter has_restricted_voice_and_video_messages : Bool?

    getter join_to_send_messages : Bool?

    getter join_by_request : Bool?

    getter description : String?

    getter invite_link : String?

    getter pinned_message : Message?

    getter permissions : ChatPermissions?

    getter slow_mode_delay : Int32?

    getter message_auto_delete_time : Int32?

    getter has_protected_content : Bool?

    getter sticker_set_name : String?

    getter can_set_sticker_set : Bool?

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

    def invite_link
      client.export_chat_invite_link(id)
    end

    def member_count
      client.get_chat_members_count(id)
    end

    def send_message(*args, **kwargs)
      client.send_message(id, *args, **kwargs)
    end

    def send_audio(audio, **kwargs)
      client.send_audio(id, audio, **kwargs)
    end

    def send_animation(animation, **kwargs)
      client.send_animation(id, animation, **kwargs)
    end

    def send_contact(phone_number, first_name, **kwargs)
      client.send_contact(id, phone_number, first_name, **kwargs)
    end

    def send_document(document, **kwargs)
      client.send_document(id, document, **kwargs)
    end

    def send_game(game_name, **kwargs)
      client.send_game(id, game_name, **kwargs)
    end

    def send_invoice(invoice, **kwargs)
      client.send_invoice(id, invoice, **kwargs)
    end

    def send_location(latitude, longitude, **kwargs)
      client.send_location(id, latitude, longitude, **kwargs)
    end

    def send_photo(photo, **kwargs)
      client.send_photo(id, photo, **kwargs)
    end

    def send_media_group(media, **kwargs)
      client.send_media_group(id, media, **kwargs)
    end

    def send_sticker(sticker, **kwargs)
      client.send_sticker(id, sticker, **kwargs)
    end

    def send_venue(latitude, longitude, title, address, **kwargs)
      client.send_venu(id, latitude, longitude, title, address, **kwargs)
    end

    def send_video(video, **kwargs)
      client.send_video(id, video, **kwargs)
    end

    def send_video_note(video_note, **kwargs)
      client.send_video(id, video_note, **kwargs)
    end

    def send_voice(voice, **kwargs)
      client.send_voice(id, voice, **kwargs)
    end

    def edit_live_location(latitude, longitude, **kwargs)
      client.edit_message_live_location(id, latitude, longitude, **kwargs)
    end

    def stop_live_location(**kwargs)
      client.stop_message_live_location(id, message_id, **kwargs)
    end

    def delete_chat_sticker_set
      client.delete_chat_sticker_set(id)
    end

    def send_chat_action(action : ChatAction)
      client.send_chat_action(id, action)
    end

    def unpin_message
      client.unpin_chat_message(id)
    end

    def set_photo(photo)
      client.set_chat_photo(id, photo)
      chat = get_chat
      @chat_photo = chat.chat_photo
    end

    def delete_photo
      client.delete_chat_photo(id)
    end

    def set_title(title)
      client.set_chat_title(id, title)
      @title = title
    end

    def set_description(description)
      client.set_chat_description(id, description)
      @description = description
    end

    def set_sticker_set(set_name)
      client.set_chat_sticker_set(id, set_name)
      @sticker_set_name = set_name
    end

    def set_administrator_custom_title(user, custom_title)
      client.set_chat_admininstrator_custom_title(id, user, custom_title)
    end

    def set_permissions(permissions)
      client.set_chat_permissions(id, permissions)
      @permissions = permissions.is_a?(ChatPermissions) ? permissions : ChatPermissions.new(permissions)
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
