module Tourmaline
  class VideoChatParticipantsInvited
    include JSON::Serializable

    getter users : Array(User)
  end
end
