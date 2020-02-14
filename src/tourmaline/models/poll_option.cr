require "json"

module Tourmaline
  # This object contains information about one answer option in a poll.
  class PollOption
    include JSON::Serializable

    getter text : String

    getter voter_count : Int32
  end
end
