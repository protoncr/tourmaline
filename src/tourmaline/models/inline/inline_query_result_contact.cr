require "json"

module Tourmaline::Model
  class InlineQueryResultContact < InlineQueryResult
    include JSON::Serializable

    getter type : String = "contact"

    getter id : String

    getter phone_number : String

    getter first_name : String

    getter last_name : String?

    getter user_id : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumb_url : String?

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @phone_number, @first_name, @last_name, @user_id, @reply_markup, @input_message_content,
                   @thumb_url, @thumb_width, @thumb_height)
    end
  end
end
