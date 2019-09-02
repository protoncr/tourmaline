require "json"

module Tourmaline::Model
  class InlineQueryResultMpeg4Gif < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "mpeg4_gif"},
      id:                    String,
      mpeg4_url:             String,
      mpeg4_width:           {type: Int32, nilable: true},
      mpeg4_height:          {type: Int32, nilable: true},
      mpeg4_duration:        {type: Int32, nilable: true},
      thumb_url:             String,
      title:                 {type: String, nilable: true},
      caption:               {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
