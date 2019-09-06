require "json"

module Tourmaline::Model
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

    def initialize(@id, @photo_file_id, @title, @description, @caption, @reply_markup, @input_message_content)
    end
  end
end
