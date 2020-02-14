require "json"

module Tourmaline
  class InlineQueryResultCachedSticker < InlineQueryResult
    include JSON::Serializable

    getter type : String = "sticker"

    getter id : String

    getter sticker_file_id : String

    getter reply_markup : InlineKeyboardMarkup

    getter input_message_content : InputMessageContent

    def initialize(@id, @sticker_file_id, @reply_markup, @input_message_content)
    end
  end
end
