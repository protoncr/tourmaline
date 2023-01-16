module Tourmaline::Model
  class VideoChatParticipantsInvited
    include JSON::Serializable

    getter users : Array(User)
  end
end
