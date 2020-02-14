require "json"

module Tourmaline
  class InputMediaDocument
    include JSON::Serializable

    getter type : String

    getter media : String

    getter thumb : (File | String)?

    getter caption : String?

    getter parse_mode : String?

    def initialize(@type : String, @media : String, @thumb : (File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil)
    end
  end
end
