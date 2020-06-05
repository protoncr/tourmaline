module Tourmaline
  class InputMediaPhoto
    include JSON::Serializable

    @type = "photo"

    property media : String | File

    property caption : String?

    property parse_mode : ParseMode?

    def initialize(@media : String, @caption : String? = nil, @parse_mode : ParseMode? = nil)
    end
  end
end
