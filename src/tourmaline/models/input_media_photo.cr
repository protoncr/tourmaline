require "json"

module Tourmaline::Model
  class InputMediaVideo
    include JSON::Serializable

    getter type : String

    getter media : String

    getter caption : String?

    getter parse_mode : String?

    def initialize(@type : String, @media : String, @caption : String? = nil, @parse_mode : String? = nil)
    end
  end
end
