require "json"

module Tourmaline::Model
  class InlineQueryResultCachedSticker < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "sticker"},
      id:                    String,
      sticker_file_id:       String,
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
