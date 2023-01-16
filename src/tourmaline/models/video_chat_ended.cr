module Tourmaline::Model
  class VideoChatEnded
    include JSON::Serializable

    getter duration : Int32
  end
end
