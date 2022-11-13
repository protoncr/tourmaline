module Tourmaline
  class ChatAdministratorRights
    include JSON::Serializable
    include Tourmaline::Model

    @[JSON::Field(key: "is_anonymous")]
    getter? anonymous : Bool

    getter? can_manage_chat : Bool

    getter? can_delete_messages : Bool

    getter? can_manage_video_chats : Bool

    getter? can_restrict_members : Bool

    getter? can_promote_members : Bool

    getter? can_change_info : Bool

    getter? can_invite_users : Bool

    getter? can_post_messages : Bool

    getter? can_edit_messages : Bool

    getter? can_pin_messages : Bool

    getter? can_manage_topics : Bool

    def initialize(
      @anonymous : Bool = false,
      @can_manage_chat : Bool = false,
      @can_delete_messages : Bool = false,
      @can_manage_video_chats : Bool = false,
      @can_restrict_members : Bool = false,
      @can_promote_members : Bool = false,
      @can_change_info : Bool = false,
      @can_invite_users : Bool = false,
      @can_post_messages : Bool = false,
      @can_edit_messages : Bool = false,
      @can_pin_messages : Bool = false,
      @can_manage_topics : Bool = false
    )
    end
  end
end
