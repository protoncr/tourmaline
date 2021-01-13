module Tourmaline
  class InputMediaDocument
    include JSON::Serializable
    include Tourmaline::Model

    @type = "document"

    property media : String | File

    property thumb : (String | File)?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    def initialize(@media, @thumb = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity)
    end
  end
end
