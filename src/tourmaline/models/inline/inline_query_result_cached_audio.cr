require "json"

module Tourmaline::Model
  class InlineQueryResultCachedAudio < InlineQueryResult
    include JSON::Serializable

    getter type : String = "audio"

    getter id : String

    getter audio_file_id : String

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id : String, @audio_file_id, @reply_markup, @input_message_content)
    end
  end
end
