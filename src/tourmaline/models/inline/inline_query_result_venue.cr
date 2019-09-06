require "json"

module Tourmaline::Model
  class InlineQueryResultVenue < InlineQueryResult
    include JSON::Serializable

    getter type : String = "venue"

    getter id : String

    getter latitude : Float64

    getter longitude : Float64

    getter title : String

    getter address : String

    getter foursquare_id : String?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumb_url : String?

    getter thumb_width : Int32?

    getter thumb_height : Int32?

    def initialize(@id, @latitude, @longitude, @title, @address, @foursquare_id, @reply_markup,
                   @input_message_content, @thumb_url, @thumb_width, @thumb_height)
    end
  end
end
