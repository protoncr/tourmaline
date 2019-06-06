require "json"

module Tourmaline::Bot::Model
  class InlineQueryResultLocation < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "location"},
      id:                    String,
      latitude:              Float64,
      longitude:             Float64,
      title:                 String,
      live_period:           {type: Int32, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
      thumb_url:             {type: String, nilable: true},
      thumb_width:           {type: Int32, nilable: true},
      thumb_height:          {type: Int32, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
