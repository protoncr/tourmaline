module Tourmaline::Model
  class VideoChatScheduled
    include JSON::Serializable

    @[JSON::Field(converter: Time::EpochConverter)]
    getter start_date : Time
  end
end
