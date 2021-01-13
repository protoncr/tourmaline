module Tourmaline
  class InlineQueryResultMpeg4Gif < InlineQueryResult
    getter type : String = "mpeg4_gif"

    getter id : String

    getter mpeg4_url : String

    getter mpeg4_width : Int32?

    getter mpeg4_height : Int32?

    getter mpeg4_duration : Int32?

    getter thumb_url : String?

    getter thumb_mime_type : String?

    getter title : String?

    getter caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @mpeg4_url, @mpeg4_width = nil, @mpeg4_height = nil, @mpeg4_duration = nil, @thumb_url = nil,
                   @title = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @reply_markup = nil, @input_message_content = nil)
    end
  end
end
