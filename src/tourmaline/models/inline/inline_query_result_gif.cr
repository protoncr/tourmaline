module Tourmaline
  class InlineQueryResultGif < InlineQueryResult
    property type : String = "gif"

    property id : String

    property gif_url : String

    property gif_width : Int32?

    property gif_height : Int32?

    property gif_duration : Int32?

    property thumb_url : String

    property thumb_mime_type : String?

    property title : String?

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property reply_markup : InlineKeyboardMarkup?

    property input_message_content : InputMessageContent?

    def initialize(@id, @gif_url, @gif_width = nil, @gif_height = nil, @gif_duration = nil, @thumb_url = nil,
                   @title = nil, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @reply_markup = nil, @input_message_content = nil)
    end
  end
end
