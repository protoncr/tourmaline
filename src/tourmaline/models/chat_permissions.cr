module Tourmaline
  class ChatPermissions
    include JSON::Serializable
    include Tourmaline::Model

    property can_send_messages : Bool

    property can_send_media_messages : Bool

    property can_send_polls : Bool

    property can_send_other_messages : Bool

    property can_add_web_page_previews : Bool

    property can_change_info : Bool

    property can_invite_users : Bool

    property can_pin_messages : Bool

    property can_manage_topics : Bool

    def initialize(
      @can_send_messages = true,
      @can_send_media_messages = true,
      @can_send_polls = true,
      @can_send_other_messages = true,
      @can_add_web_page_previews = true,
      @can_change_info = true,
      @can_invite_users = true,
      @can_pin_messages = true,
      @can_manage_topics = true
    )
    end
  end
end
