require "json"

module Tourmaline::Model
  class InlineQueryResultCachedMpeg4Gif < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "mpeg4_gif"},
      id:                    String,
      mpeg4_file_id:         String,
      title:                 {type: String, nilable: true},
      caption:               {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
