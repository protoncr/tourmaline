require "json"

module Tourmaline::Model
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

    def initialize(@id, @video_file_id, @title, @caption, @description, @reply_markup, @input_message_content)
    end
  end
end
