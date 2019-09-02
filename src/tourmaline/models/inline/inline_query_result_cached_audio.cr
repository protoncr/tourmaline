require "json"

module Tourmaline::Model
  class InlineQueryResultCachedAudio < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "audio"},
      id:                    String,
      audio_file_id:         String,
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
