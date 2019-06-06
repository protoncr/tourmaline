require "json"

module Tourmaline::Bot::Model
  class InlineQueryResultAudio < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "audio"},
      id:                    String,
      audio_url:             String,
      title:                 String,
      performer:             {type: String, nilable: true},
      audio_duration:        {type: Int32, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
