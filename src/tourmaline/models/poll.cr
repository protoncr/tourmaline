require "json"
require "../client/polls"

module Tourmaline
  # This object contains information about a poll.
  class Poll
    include JSON::Serializable

    getter id : String

    getter question : String

    getter options : Array(PollOption)

    getter total_voter_count : Int32

    getter is_closed : Bool

    getter is_anonymous : Bool

    @[JSON::Field(converter: Tourmaline::Poll::PollTypeConverter)]
    getter type : PollType

    getter allows_multiple_answers : Bool

    getter correct_option_id : Int32?

    # :nodoc:
    module PollTypeConverter
      def self.from_json(value : JSON::PullParser)
        PollType.parse(value.read_string)
      end

      def self.to_json(value : PollType, json : JSON::Builder)
        json.string(value.to_s)
      end
    end
  end
end
