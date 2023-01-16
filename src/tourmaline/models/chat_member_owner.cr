module Tourmaline::Model
  class ChatMemberOwner
    include JSON::Serializable

    getter status : String

    getter user : User

    @[JSON::Field(key: "is_anonymous")]
    getter? anonymous : Bool

    getter custom_title : String?
  end
end
