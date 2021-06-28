module Tourmaline
  class VoiceChatEnded
    include JSON::Serializable
    include Tourmaline::Model

    getter duration : Int32
  end
end
