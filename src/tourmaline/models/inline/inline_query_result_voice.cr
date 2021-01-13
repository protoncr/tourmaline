module Tourmaline
  class InlineQueryResultVoice < InlineQueryResult

    property type : String = "voice"

    property id : String

    property voice_url : String

    property title : String

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property voice_duration : Int32?

    property reply_markup : InlineKeyboardMarkup?

    property input_message_content : InputMessageContent?

    def initialize(@id, @voice_url, @title, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity,
                   @voice_duration = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
