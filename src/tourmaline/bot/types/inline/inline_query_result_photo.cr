require "json"

module Tourmaline::Bot
  class InlineQueryResultPhoto < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "photo"},
      id:                    String,
      photo_url:             String,
      thumb_url:             String,
      photo_width:           {type: Int32, nilable: true},
      photo_height:          {type: Int32, nilable: true},
      title:                 {type: String, nilable: true},
      description:           {type: String, nilable: true},
      caption:               {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
