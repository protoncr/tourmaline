require "json"

module Tourmaline
  class InlineQueryResultAudio < InlineQueryResult
    include JSON::Serializable

    getter type : String = "audio"

    getter id : String

    getter audio_url : String

    getter title : String

    getter performer : String?

    getter audio_duration : Int32?

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @audio_url, @title, @performer = nil, @audio_duration = nil, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
