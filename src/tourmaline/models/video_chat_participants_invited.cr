module Tourmaline
  class VideoChatParticipantsInvited
    include JSON::Serializable
    include Tourmaline::Model

    getter users : Array(User)
  end
end
