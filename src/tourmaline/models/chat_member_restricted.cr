require "./chat_member_member"

module Tourmaline
  class ChatMemberRestricted < ChatMemberMember
    @[JSON::Field(key: "is_member")]
    getter? member : Bool

    getter? can_change_info : Bool

    getter? can_invite_users : Bool

    getter? can_pin_messages : Bool

    getter? can_manage_topics : Bool

    getter? can_send_messages : Bool

    getter? can_send_media_messages : Bool

    getter? can_send_polls : Bool

    getter? can_send_other_messages : Bool

    getter? can_add_web_page_previews : Bool

    getter custom_title : String?
  end
end
