require "json"

module Tourmaline::Model
  class InlineQueryResultDocument < InlineQueryResult
    include JSON::Serializable

    getter type : String = "document"

    getter id : String

    getter title : String

    getter caption : String?

    getter document_url : String

    getter mime_type : String

    getter description : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumb_url : String

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @title, @caption, @document_url, @mime_type, @description,
                   @reply_markup, @input_message_content, @thumb_url, @thumb_width, @thumb_height)
    end
  end
end
