module Tourmaline
  class InputMediaDocument
    include JSON::Serializable

    @type = "document"

    property media : String | File

    property thumb : (String | File)?

    property caption : String?

    property parse_mode : ParseMode?

    def initialize(@media : String, @thumb : (File | String)? = nil, @caption : String? = nil, @parse_mode : ParseMode? = nil)
    end
  end
end
