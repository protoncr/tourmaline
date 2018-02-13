require "json"

module Tourmaline::Bot
  class InlineQueryResultVenue < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "venue"},
      id:                    String,
      latitude:              Float64,
      longitude:             Float64,
      title:                 String,
      address:               String,
      foursquare_id:         {type: String, nilable: true},
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
