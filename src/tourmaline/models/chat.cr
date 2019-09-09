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

    def invite_link
      BotContainer.bot.export_chat_invite_link(id)
    end

    def member_count
      BotContainer.bot.get_chat_members_count(id)
    end

    def send_message(*args, **kwargs)
      BotContainer.bot.send_message(id, *args, **kwargs)
    end

    def unpin_message
      BotContainer.bot.unpin_chat_message(id)
    end

    def set_photo(photo)
      BotContainer.bot.set_chat_photo(id, photo)
      chat = BotContainer.get_chat
      @chat_photo = chat.chat_photo
    end

    def delete_photo
      BotContainer.bot.delete_chat_photo(id)
    end

    def set_title(title)
      BotContainer.bot.set_chat_title(id, title)
      @title = title
    end

    def set_description(description)
      BotContainer.bot.set_chat_description(id, description)
      @description = description
    end

    def set_sticker_set(set_name)
      BotContainer.bot.set_chat_sticker_set(id, set_name)
      @sticker_set_name = set_name
    end

    def set_permissions(permissions)
      BotContainer.bot.set_chat_permissions(id, permissions)
      @permissions = permissions.is_a?(ChatPermissions) ? permissions : ChatPermissions.new(permissions)
    end
  end
end
