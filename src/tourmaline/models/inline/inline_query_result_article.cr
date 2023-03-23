module Tourmaline
  class InlineQueryResultArticle < InlineQueryResult
    getter type : String = "article"

    getter id : String

    getter title : String

    getter input_message_content : InputMessageContent

    getter reply_markup : InlineKeyboardMarkup?

    getter url : String?

    getter hide_url : Bool?

    getter description : String?

    getter thumbnail_url : String?

    getter thumbnail_width : Int32?

    getter thumbnail_height : Int32?

    def initialize(@id, @title, @input_message_content, @reply_markup = nil, @url = nil, @hide_url = nil, @description = nil, @thumbnail_url = nil, @thumbnail_width = nil, @thumbnail_height = nil)
    end
  end
end
