require "json"

module Tourmaline
  class ChatMember
    include JSON::Serializable

    property! chat_id : Int64

    getter user : User

    getter status : String

    getter custom_title : String?

    @[JSON::Field(converter: Time::EpochMillisConverter)]
    getter until_date : Time?

    getter can_be_edited : Bool?

    getter can_change_info : Bool?

    getter can_post_messages : Bool?

    getter can_edit_messages : Bool?

    getter can_delete_messages : Bool?

    getter can_invite_users : Bool?

    getter can_restrict_members : Bool?

    getter can_promote_members : Bool?

    getter can_send_messages : Bool?

    getter can_send_media_messages : Bool?

    getter can_send_other_messages : Bool?

    getter can_add_web_page_previews : Bool?

    def kick(until_date = nil)
      Container.client.kick_chat_member(chat_id, user.id, until_date)
    end

    def unban
      Container.client.unban_chat_member(chat_id, user.id)
    end

    def restrict(permissions, until_date = nil)
      case permissions
      when true
        Container.client.restrict_chat_member(chat_id, user.id, {
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
        Container.client.restrict_chat_member(chat_id, user.id, {
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
        Container.client.restrict_chat_member(chat_id, user.id, permissions, until_date)
      end
    end

    def promote(**permissions)
      Container.client.promote_chat_member(chat_id, user.id, **permissions)
    end

    def self.from_user(user)
      uid = user.is_a?(User) ? user.id : user
      Container.get_chat_member(id, uid)
    end
  end
end
