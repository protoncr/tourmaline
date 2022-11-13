module Tourmaline
  class ChatMemberAdministrator
    include JSON::Serializable
    include Tourmaline::Model

    getter status : String

    getter user : User

    getter can_be_edited : Bool

    @[JSON::Field(key: "is_anonymous")]
    getter? anonymous : Bool?

    getter? can_manage_chat : Bool

    getter? can_delete_messages : Bool

    getter? can_manage_video_chats : Bool

    getter? can_restrict_members : Bool

    getter? can_promote_members : Bool

    getter? can_change_info : Bool

    getter? can_invite_users : Bool

    getter? can_post_messages : Bool?

    getter? can_edit_messages : Bool?

    getter? can_pin_messages : Bool?

    getter? can_manage_topics : Bool?

    getter custom_title : String?
  end
end
