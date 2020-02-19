require "json"

module Tourmaline
  class InputMediaAudio
    include JSON::Serializable

    @type = "audio"

    property media : String | ::File

    property thumb : (String | ::File)?

    property caption : String?

    property parse_mode : String?

    property duration : Int32?

    property performer : String?

    property title : String?

    def initialize(@media : String, @thumb : (::File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil,
                   duration : Int32? = nil, @performer : String? = nil, @title : String? = nil)
    end
  end
end
