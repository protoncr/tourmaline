module Tourmaline
  class VoiceChatParticipantsInvited
    include JSON::Serializable
    include Tourmaline::Model

    getter users : Array(User)
  end
end
