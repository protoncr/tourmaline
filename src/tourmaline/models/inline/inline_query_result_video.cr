require "json"

module Tourmaline
  class InlineQueryResultVideo < InlineQueryResult
    include JSON::Serializable

    getter type : String = "video"

    getter id : String

    getter video_url : String

    getter mime_type : String

    getter thumb_url : String

    getter title : String

    getter caption : String?

    getter video_width : Int32?

    getter video_height : Int32?

    getter video_duration : Int32?

    getter description : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @video_url, @mime_type, @thumb_url, @title, @caption = nil, @video_width = nil,
                   @video_height = nil, @video_duration = nil, @description = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
