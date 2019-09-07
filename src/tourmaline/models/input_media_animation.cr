require "json"

module Tourmaline::Model
  class InputMediaAnimation
    include JSON::Serializable

    getter type : String

    getter media : String

    getter thumb : (File | String)?

    getter caption : String?

    getter parse_mode : String?

    getter width : Int32?

    getter height : Int32?

    getter duration : Int32?

    def initialize(@type : String, @media : String, @thumb : (File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil,
                   @width : Int32? = nil, @height : Int32? = nil, duration : Int32? = nil)
    end
  end
end
