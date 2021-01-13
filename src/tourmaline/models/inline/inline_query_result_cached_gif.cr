module Tourmaline
  class InlineQueryResultCachedGif < InlineQueryResult
    getter type : String = "gif"

    getter id : String

    getter gif_file_id : String

    getter title : String?

    getter caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @gif_file_id, @title = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
