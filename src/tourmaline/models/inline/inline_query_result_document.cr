require "json"

module Tourmaline::Model
  class InlineQueryResultDocument < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "document"},
      id:                    String,
      title:                 String,
      caption:               {type: String, nilable: true},
      document_url:          String,
      mime_type:             String,
      description:           {type: String, nilable: true},
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
