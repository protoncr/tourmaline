require "json"

module Tourmaline::Model
  class InlineQueryResultPhoto < InlineQueryResult
    include JSON::Serializable

    getter type : String = "photo"

    getter id : String

    getter photo_url : String

    getter thumb_url : String

    getter photo_width : Int32?

    getter photo_height : Int32?

    getter title : String?

    getter description : String?

    getter caption : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @photo_url, @thumb_url, @photo_width, @photo_height,
                   @title, @description, @caption, @reply_markup, @input_message_content)
    end
  end
end
