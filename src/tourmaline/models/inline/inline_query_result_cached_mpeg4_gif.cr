require "json"

module Tourmaline::Model
  class InlineQueryResultCachedMpeg4Gif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "mpeg4_gif"

    getter id : String

    getter mpeg4_file_id : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @mpeg4_file_id, @title, @caption, @reply_markup, @input_message_content)
    end
  end
end
