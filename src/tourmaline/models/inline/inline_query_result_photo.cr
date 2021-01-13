module Tourmaline
  class InlineQueryResultPhoto < InlineQueryResult
    property type : String = "photo"

    property id : String

    property photo_url : String

    property thumb_url : String

    property photo_width : Int32?

    property photo_height : Int32?

    property title : String?

    property description : String?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property reply_markup : InlineKeyboardMarkup?

    property input_message_content : InputMessageContent?

    def initialize(@id, @photo_url, @thumb_url, @photo_width = nil, @photo_height = nil, @title = nil,
                   @description = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @reply_markup = nil, @input_message_content = nil)
    end
  end
end
