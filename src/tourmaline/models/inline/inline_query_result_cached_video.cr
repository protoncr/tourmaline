module Tourmaline::Model
  class InlineQueryResultCachedVideo < InlineQueryResult
    getter type : String = "video"

    getter id : String

    getter video_file_id : String

    getter title : String

    getter caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    getter description : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @video_file_id, @title, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @description = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
