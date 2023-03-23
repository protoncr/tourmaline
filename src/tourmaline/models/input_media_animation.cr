module Tourmaline
  class InputMediaAnimation
    include JSON::Serializable

    @type = "animation"

    property media : String | File

    property thumb : (String | File)?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property? has_spoiler : Bool

    property width : Int32?

    property height : Int32?

    property duration : Int32?

    def initialize(@media, @thumb = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @has_spoiler = false, @width = nil, @height = nil, @duration = nil)
    end
  end
end
