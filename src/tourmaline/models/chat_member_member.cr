module Tourmaline::Model
  class ChatMemberMember
    include JSON::Serializable

    getter status : String

    getter user : User
  end
end
