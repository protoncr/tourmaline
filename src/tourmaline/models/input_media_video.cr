module Tourmaline
  class InputMediaVideo
    include JSON::Serializable
    include Tourmaline::Model

    @type = "video"

    property media : String | File

    property thumb : (String | File)?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property width : Int32?

    property height : Int32?

    property duration : Int32?

    property supports_streaming : Bool?

    def initialize(@media, @thumb = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @width = nil, @height = nil, duration = nil, @supports_streaming = nil)
    end
  end
end
