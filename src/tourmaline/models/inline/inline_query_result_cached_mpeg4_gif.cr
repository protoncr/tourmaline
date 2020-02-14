require "json"

module Tourmaline
  class InlineQueryResultCachedMpeg4Gif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "mpeg4_gif"

    getter id : String

    getter mpeg4_file_id : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @mpeg4_file_id, @title = nil, @caption = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
