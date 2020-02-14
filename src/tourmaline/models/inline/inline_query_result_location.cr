require "json"

module Tourmaline
  class InlineQueryResultLocation < InlineQueryResult
    include JSON::Serializable

    getter type : String = "location"

    getter id : String

    getter latitude : Float64

    getter longitude : Float64

    getter title : String

    getter live_period : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumb_url : String?

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @latitude, @longitude, @title, @live_period = nil, @reply_markup = nil,
                   @input_message_content = nil, @thumb_url = nil, @thumb_width = nil, @thumb_height = nil)
    end
  end
end
