require "json"

module Tourmaline::Model
  class InlineQueryResultCachedGif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "gif"

    getter id : String

    getter gif_file_id : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @gif_file_id, @title, @caption, @reply_markup, @input_message_content)
    end
  end
end
