module Tourmaline
  class ChatJoinRequest
    include JSON::Serializable

    getter chat : Chat

    getter from : User

    getter user_chat_id : Int64

    getter date : Int64

    getter bio : String?

    getter invite_link : ChatInviteLink?
  end
end
