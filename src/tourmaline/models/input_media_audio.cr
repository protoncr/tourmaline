module Tourmaline
  class InputMediaAudio
    include JSON::Serializable
    include Tourmaline::Model

    @type = "audio"

    property media : String | File

    property thumb : (String | File)?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property duration : Int32?

    property performer : String?

    property title : String?

    def initialize(@media, @thumb = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   duration = nil, @performer = nil, @title = nil)
    end
  end
end
