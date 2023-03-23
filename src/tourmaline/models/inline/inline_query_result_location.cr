module Tourmaline
  class InlineQueryResultLocation < InlineQueryResult
    getter type : String = "location"

    getter id : String

    getter latitude : Float64

    getter longitude : Float64

    getter title : String

    getter horizontal_accuracy : Int32?

    getter live_period : Int32?

    getter heading : Int32?

    getter proximity_alert_radius : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    getter thumbnail_url : String?

    getter thumbnail_width : Int32?

    getter thumbnail_height : Int32?

    def initialize(@id, @latitude, @longitude, @title, @live_period = nil, @reply_markup = nil,
                   @input_message_content = nil, @thumbnail_url = nil, @thumbnail_width = nil, @thumbnail_height = nil)
    end
  end
end
