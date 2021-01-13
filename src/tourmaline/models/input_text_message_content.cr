module Tourmaline
  class InputTextMessageContent
    include JSON::Serializable
    include Tourmaline::Model

    getter message_text : String

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    getter disable_web_page_preview : Bool?

    def initialize(@message_text, @parse_mode = nil, @caption_entities = [] of MessageEntity, @disable_web_page_preview = nil)
    end
  end
end
