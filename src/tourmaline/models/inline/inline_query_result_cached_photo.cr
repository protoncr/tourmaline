require "json"

module Tourmaline
  class InlineQueryResultCachedPhoto < InlineQueryResult
    include JSON::Serializable

    getter type : String = "photo"

    getter id : String

    getter photo_file_id : String

    getter title : String?

    getter description : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @photo_file_id, @title = nil, @description = nil, @caption = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
