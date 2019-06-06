require "json"

module Tourmaline::Bot::Model
  class InlineQueryResultGif < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "gif"},
      id:                    String,
      gif_url:               String,
      gif_width:             {type: Int32, nilable: true},
      gif_height:            {type: Int32, nilable: true},
      gif_duration:          {type: Int32, nilable: true},
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
