module Tourmaline
  class ChatInviteLink
    include JSON::Serializable
    include Tourmaline::Model

    getter invite_link : String

    getter creator : User

    @[JSON::Field(key: "is_primary")]
    getter? primary : Bool

    @[JSON::Field(key: "is_revoked")]
    getter? revoked : Bool

    @[JSON::Field(converter: Time::EpochConverter)]
    getter expire_date : Time?

    getter member_limit : Int32?
  end
end
