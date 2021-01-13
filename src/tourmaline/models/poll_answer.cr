module Tourmaline
  # This object contains information about one answer option in a poll.
  class PollAnswer
    include JSON::Serializable
    include Tourmaline::Model

    getter poll_id : String

    getter user : User

    getter option_ids : Array(Int32)
  end
end
