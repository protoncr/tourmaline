require "json"

module Tourmaline
  class InlineQueryResultCachedVoice < InlineQueryResult
    include JSON::Serializable

    getter type : String = "voice"

    getter id : String

    getter voice_file_id : String

    getter title : String

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id, @voice_file_id, @title, @reply_markup = nil, @input_message_content = nil)
    end
  end
end
