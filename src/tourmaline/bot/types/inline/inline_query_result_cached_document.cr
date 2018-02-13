require "json"

module Tourmaline::Bot
  class InlineQueryResultCachedDocument < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "document"},
      id:                    String,
      title:                 String,
      document_file_id:      String,
      description:           {type: String, nilable: true},
      caption:               {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
