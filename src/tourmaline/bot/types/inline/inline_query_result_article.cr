require "json"

module Tourmaline::Bot
  class InlineQueryResultArticle < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "article"},
      id:                    String,
      title:                 String,
      input_message_content: InputMessageContent,
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      url:                   {type: String, nilable: true},
      hide_url:              {type: Bool, nilable: true},
      description:           {type: String, nilable: true},
      thumb_url:             {type: String, nilable: true},
      thumb_width:           {type: Int32, nilable: true},
      thumb_height:          {type: Int32, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
