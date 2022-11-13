module Tourmaline
  class ChatMemberMember
    include JSON::Serializable
    include Tourmaline::Model

    getter status : String

    getter user : User

    def kick(until_date = nil)
      client.kick_chat_member(chat_id, user.id, until_date)
    end

    def unban
      client.unban_chat_member(chat_id, user.id)
    end

    def restrict(permissions, until_date = nil)
      case permissions
      when true
        client.restrict_chat_member(chat_id, user.id, {
          can_send_messages:         true,
          can_send_media_messages:   true,
          can_send_polls:            true,
          can_send_other_messages:   true,
          can_add_web_page_previews: true,
          can_change_info:           true,
          can_invite_users:          true,
          can_pin_messages:          true,
        }, until_date)
      when false
        client.restrict_chat_member(chat_id, user.id, {
          can_send_messages:         false,
          can_send_media_messages:   false,
          can_send_polls:            false,
          can_send_other_messages:   false,
          can_add_web_page_previews: false,
          can_change_info:           false,
          can_invite_users:          false,
          can_pin_messages:          false,
        }, until_date)
      else
        client.restrict_chat_member(chat_id, user.id, permissions, until_date)
      end
    end

    def promote(**permissions)
      client.promote_chat_member(chat_id, user.id, **permissions)
    end

    def self.from_user(user)
      uid = user.is_a?(User) ? user.id : user
      get_chat_member(id, uid)
    end
  end
end
