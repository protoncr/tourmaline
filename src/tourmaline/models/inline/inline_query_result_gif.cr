require "json"

module Tourmaline::Model
  class InlineQueryResultGif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "gif"

    getter id : String

    getter gif_url : String

    getter gif_width : Int32?

    getter gif_height : Int32?

    getter gif_duration : Int32?

    getter thumb_url : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @gif_url, @gif_width, @gif_height, @gif_duration, @thumb_url,
                   @title, @caption, @reply_markup, @input_message_content)
    end
  end
end
