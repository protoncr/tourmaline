module Tourmaline
  class VoiceChatScheduled
    include JSON::Serializable
    include Tourmaline::Model

    @[JSON::Field(converter: Time::EpochConverter)]
    getter start_date : Time
  end
end
