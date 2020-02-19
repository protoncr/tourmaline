require "json"

module Tourmaline
  class InputMediaDocument
    include JSON::Serializable

    @type = "document"

    property media : String | ::File

    property thumb : (String | ::File)?

    property caption : String?

    property parse_mode : String?

    def initialize(@media : String, @thumb : (::File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil)
    end
  end
end
