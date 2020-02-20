require "json"

module Tourmaline
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

    getter slow_mode_delay : Int32?

    getter sticker_set_name : String?

    getter can_set_sticker_set : Bool?

    def invite_link
      Container.client.export_chat_invite_link(id)
    end

    def member_count
      Container.client.get_chat_members_count(id)
    end

    def send_message(*args, **kwargs)
      Container.client.send_message(id, *args, **kwargs)
    end

    def send_audio(audio, **kwargs)
      Container.client.send_audio(id, audio, **kwargs)
    end

    def send_animation(animation, **kwargs)
      Container.client.send_animation(id, animation, **kwargs)
    end

    def send_contact(phone_number, first_name, **kwargs)
      Container.client.send_contact(id, phone_number, first_name, **kwargs)
    end

    def send_document(document, **kwargs)
      Container.client.send_document(id, document, **kwargs)
    end

    def send_game(game_name, **kwargs)
      Container.client.send_game(id, game_name, **kwargs)
    end

    def send_invoice(invoice, **kwargs)
      Container.client.send_invoice(id, invoice, **kwargs)
    end

    def send_location(latitude, longitude, **kwargs)
      Container.client.send_location(id, latitude, longitude, **kwargs)
    end

    def send_photo(photo, **kwargs)
      Container.client.send_photo(id, photo, **kwargs)
    end

    def send_media_group(media, **kwargs)
      Container.client.send_media_group(id, media, **kwargs)
    end

    def send_sticker(sticker, **kwargs)
      Container.client.send_sticker(id, sticker, **kwargs)
    end

    def send_venue(latitude, longitude, title, address, **kwargs)
      Container.client.send_venu(id, latitude, longitude, title, address, **kwargs)
    end

    def send_video(video, **kwargs)
      Container.client.send_video(id, video, **kwargs)
    end

    def send_video_note(video_note, **kwargs)
      Container.client.send_video(id, video_note, **kwargs)
    end

    def send_voice(voice, **kwargs)
      Container.client.send_voice(id, voice, **kwargs)
    end

    def edit_live_location(latitude, longitude, **kwargs)
      Container.client.edit_message_live_location(id, latitude, longitude, **kwargs)
    end

    def stop_live_location(**kwargs)
      Container.client.stop_message_live_location(id, message_id, **kwargs)
    end

    def delete_chat_sticker_set
      Container.client.delete_chat_sticker_set(id)
    end

    def send_chat_action(action : ChatAction)
      Container.client.send_chat_action(id, action)
    end

    def unpin_message
      Container.client.unpin_chat_message(id)
    end

    def set_photo(photo)
      Container.client.set_chat_photo(id, photo)
      chat = Container.get_chat
      @chat_photo = chat.chat_photo
    end

    def delete_photo
      Container.client.delete_chat_photo(id)
    end

    def set_title(title)
      Container.client.set_chat_title(id, title)
      @title = title
    end

    def set_description(description)
      Container.client.set_chat_description(id, description)
      @description = description
    end

    def set_sticker_set(set_name)
      Container.client.set_chat_sticker_set(id, set_name)
      @sticker_set_name = set_name
    end

    def set_administrator_custom_title(user, custom_title)
      Container.client.set_chat_admininstrator_custom_title(id, user, custom_title)
    end

    def set_permissions(permissions)
      Container.client.set_chat_permissions(id, permissions)
      @permissions = permissions.is_a?(ChatPermissions) ? permissions : ChatPermissions.new(permissions)
    end
  end
end
