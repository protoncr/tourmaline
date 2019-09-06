require "json"

module Tourmaline::Model
  class ChatMember
    include JSON::Serializable

    getter user : User

    getter status : String

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
  end
end
