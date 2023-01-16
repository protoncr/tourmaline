module Tourmaline::Model
  class InlineQueryResultCachedMpeg4Gif < InlineQueryResult
    getter type : String = "mpeg4_gif"

    getter id : String

    getter mpeg4_file_id : String

    getter title : String?

    getter caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @mpeg4_file_id, @title = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
