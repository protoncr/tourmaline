require "json"

module Tourmaline
  class InlineQueryResultCachedGif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "gif"

    getter id : String

    getter gif_file_id : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @gif_file_id, @title = nil, @caption = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
