module Tourmaline
  class ChatMemberUpdated
    include JSON::Serializable
    include Tourmaline::Model

    getter chat : Chat

    getter from : User

    @[JSON::Field(converter: Time::EpochConverter)]
    getter date : Time

    getter old_chat_member : ChatMember

    getter new_chat_member : ChatMember

    getter invite_link : ChatInviteLink?
  end
end
