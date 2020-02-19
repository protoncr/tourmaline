require "json"

module Tourmaline
  class InputMediaVideo
    include JSON::Serializable

    @type = "video"

    property media : String | ::File

    property thumb : (String | ::File)?

    property caption : String?

    property parse_mode : String?

    property width : Int32?

    property height : Int32?

    property duration : Int32?

    property supports_streaming : Bool?

    def initialize(@media : String, @thumb : (::File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil,
                   @width : Int32? = nil, @height : Int32? = nil, duration : Int32? = nil, @supports_streaming : Bool? = nil)
    end
  end
end
