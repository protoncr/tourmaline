module Tourmaline
  class InlineQueryResultContact < InlineQueryResult
    getter type : String = "contact"

    getter id : String

    getter phone_number : String

    getter first_name : String

    getter last_name : String?

    getter user_id : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumbnail_url : String?

    getter thumbnail_width : Int32?

    getter thumbnail_height : Int32?

    def initialize(@id, @phone_number, @first_name, @last_name = nil, @user_id = nil, @reply_markup = nil, @input_message_content = nil,
                   @thumbnail_url = nil, @thumbnail_width = nil, @thumbnail_height = nil)
    end
  end
end
