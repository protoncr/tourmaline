require "json"

module Tourmaline
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

    def initialize(@id, @gif_url, @gif_width = nil, @gif_height = nil, @gif_duration = nil, @thumb_url = nil,
                   @title = nil, @caption = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
