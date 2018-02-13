require "json"

module Tourmaline::Bot
  class InlineQueryResultCachedVoice < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "voice"},
      id:                    String,
      voice_file_id:         String,
      title:                 String,
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
