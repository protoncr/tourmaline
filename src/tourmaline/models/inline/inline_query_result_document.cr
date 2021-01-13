module Tourmaline
  class InlineQueryResultDocument < InlineQueryResult
    getter type : String = "document"

    getter id : String

    getter title : String

    getter caption : String?

    property caption : String?

    property parse_mode : ParseMode?

    getter document_url : String

    getter mime_type : String

    getter description : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumb_url : String

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @title, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @document_url = nil, @mime_type = nil, @description = nil, @reply_markup = nil,
                   @input_message_content = nil, @thumb_url = nil, @thumb_width = nil, @thumb_height = nil)
    end
  end
end
