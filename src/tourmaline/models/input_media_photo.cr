require "json"

module Tourmaline
  class InputMediaPhoto
    include JSON::Serializable

    @type = "photo"

    property media : String | ::File

    property caption : String?

    property parse_mode : String?

    def initialize(@media : String, @caption : String? = nil, @parse_mode : String? = nil)
    end
  end
end
