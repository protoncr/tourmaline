require "json"

module Tourmaline::Model
  class InlineQueryResultVoice < InlineQueryResult
    include JSON::Serializable

    getter type : String = "voice"

    getter id : String

    getter voice_url : String

    getter title : String

    getter voice_duration : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @voice_url, @title, @voice_duration, @reply_markup, @input_message_content)
    end
  end
end
