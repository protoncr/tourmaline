require "json"

module Tourmaline::Model
  class InlineQueryResultMpeg4Gif < InlineQueryResult
    include JSON::Serializable

    getter type : String = "mpeg4_gif"

    getter id : String

    getter mpeg4_url : String

    getter mpeg4_width : Int32?

    getter mpeg4_height : Int32?

    getter mpeg4_duration : Int32?

    getter thumb_url : String

    getter title : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @mpeg4_url, @mpeg4_width, @mpeg4_height, @mpeg4_duration, @thumb_url,
                   @title, @caption, @reply_markup, @input_message_content)
    end
  end
end
