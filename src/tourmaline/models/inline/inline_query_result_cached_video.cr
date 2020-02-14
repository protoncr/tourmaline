require "json"

module Tourmaline
  class InlineQueryResultCachedVideo < InlineQueryResult
    include JSON::Serializable

    getter type : String = "video"

    getter id : String

    getter video_file_id : String

    getter title : String

    getter caption : String?

    getter description : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @video_file_id, @title, @caption = nil, @description = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
