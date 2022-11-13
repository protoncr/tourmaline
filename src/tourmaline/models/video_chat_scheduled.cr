module Tourmaline
  class VideoChatScheduled
    include JSON::Serializable
    include Tourmaline::Model

    @[JSON::Field(converter: Time::EpochConverter)]
    getter start_date : Time
  end
end
