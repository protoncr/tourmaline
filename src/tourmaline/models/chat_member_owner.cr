module Tourmaline
  class ChatMemberOwner
    include JSON::Serializable
    include Tourmaline::Model

    getter status : String

    getter user : User

    @[JSON::Field(key: "is_anonymous")]
    getter? anonymous : Bool

    getter custom_title : String?
  end
end
