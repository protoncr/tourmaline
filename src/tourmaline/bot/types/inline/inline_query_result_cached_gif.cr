require "json"

module Tourmaline::Bot
  class InlineQueryResultCachedGif < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "gif"},
      id:                    String,
      gif_file_id:           String,
      title:                 {type: String, nilable: true},
      caption:               {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
