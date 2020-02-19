require "json"

module Tourmaline
  class InputMediaAnimation
    include JSON::Serializable

    @type = "animation"

    property media : String | ::File

    property thumb : (String | ::File)?

    property caption : String?

    property parse_mode : String?

    property width : Int32?

    property height : Int32?

    property duration : Int32?

    def initialize(@media : String, @thumb : (::File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil,
                   @width : Int32? = nil, @height : Int32? = nil, duration : Int32? = nil)
    end
  end
end
