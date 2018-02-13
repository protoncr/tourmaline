require "json"

module Tourmaline::Bot
  class InlineQueryResultCachedVideo < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "video"},
      id:                    String,
      video_file_id:         String,
      title:                 String,
      caption:               {type: String, nilable: true},
      description:           {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
