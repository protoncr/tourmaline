require "./chat_member_member"

module Tourmaline
  class ChatMemberBanned < ChatMemberMember
    @[JSON::Field(converter: Time::EpochConverter)]
    getter until_date : Time
  end
end
