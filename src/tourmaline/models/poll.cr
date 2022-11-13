require "json"

module Tourmaline
  # This object contains information about a poll.
  class Poll
    include JSON::Serializable
    include Tourmaline::Model

    getter id : String

    getter question : String

    getter options : Array(PollOption)

    getter total_voter_count : Int32

    @[JSON::Field(key: "is_closed")]
    getter? closed : Bool

    @[JSON::Field(key: "is_anonymous")]
    getter? anonymous : Bool

    @[JSON::Field(converter: Tourmaline::Poll::PollTypeConverter)]
    getter type : Type

    getter allows_multiple_answers : Bool

    getter correct_option_id : Int32?

    getter explanation_entities : Array(Tourmaline::MessageEntity) = [] of Tourmaline::MessageEntity

    enum Type
      Quiz
      Regular

      def to_s
        super.to_s.downcase
      end
    end

    # :nodoc:
    module PollTypeConverter
      def self.from_json(value : JSON::PullParser)
        Type.parse(value.read_string)
      end

      def self.to_json(value : Type, json : JSON::Builder)
        json.string(value.to_s)
      end
    end
  end
end
