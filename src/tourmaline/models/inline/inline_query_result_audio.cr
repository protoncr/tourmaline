require "json"

module Tourmaline::Model
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

    def initialize(@id, @audio_url, @title, @performer, @audio_duration, @reply_markup, @input_message_content)
    end
  end
end
