module Tourmaline
  class InlineQueryResultVideo < InlineQueryResult
    property type : String = "video"

    property id : String

    property video_url : String

    property mime_type : String

    property thumb_url : String

    property title : String

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property video_width : Int32?

    property video_height : Int32?

    property video_duration : Int32?

    property description : String?

    property reply_markup : InlineKeyboardMarkup?

    property input_message_content : InputMessageContent?

    def initialize(@id, @video_url, @mime_type, @thumb_url, @title, @caption = nil, @parse_mode = nil,
                   @caption_entities = [] of MessageEntity, @video_width = nil, @video_height = nil,
                   @video_duration = nil, @description = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
