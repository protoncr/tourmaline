require "json"

module Tourmaline::Bot::Model
  class InlineQueryResultContact < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "contact"},
      id:                    String,
      phone_number:          String,
      first_name:            String,
      last_name:             {type: String, nilable: true},
      user_id:               {type: Int32, nilable: true},
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
