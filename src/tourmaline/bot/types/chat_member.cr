require "json"

module Tourmaline::Bot
  struct ChatMember
    JSON.mapping(

      user: User,

      status: String,

      until_date: {type: Time, converter: Time::EpochMillisConverter, nilable: true},

      can_be_edited: Bool?,

      can_change_info: Bool?,

      can_post_messages: Bool?,

      can_edit_messages: Bool?,

      can_delete_messages: Bool?,

      can_invite_users: Bool?,

      can_restrict_members: Bool?,

      can_promote_members: Bool?,

      can_send_messages: Bool?,

      can_send_media_messages: Bool?,

      can_send_other_messages: Bool?,

      can_add_web_page_previews: Bool?
    )
  end
end
