module Tourmaline
  class InlineQueryResultCachedDocument < InlineQueryResult

    property type : String = "document"

    property id : String

    property title : String

    property document_file_id : String

    property description : String?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property reply_markup : InlineKeyboardMarkup?

    property input_message_content : InputMessageContent?

    def initialize(@id, @title, @document_file_id, @description = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
