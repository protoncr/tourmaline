require "json"

module Tourmaline::Model
  class InlineQueryResultArticle < InlineQueryResult
    include JSON::Serializable

    getter type : String = "article"

    getter id : String

    getter title : String

    getter input_message_content : InputMessageContent

    getter reply_markup : InlineKeyboardMarkup?

    getter url : String?

    getter hide_url : Bool?

    getter thumb_url : String?

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @title, @input_message_content, @reply_markup, @url, @hide_url, @thumb_url, @thumb_width, @thumb_height)
    end
  end
end
