require "json"

module Tourmaline::Model
  class InlineQueryResultVideo < InlineQueryResult
    FIELDS = {
      type:                  {type: String, mustbe: "video"},
      id:                    String,
      video_url:             String,
      mime_type:             String,
      thumb_url:             String,
      title:                 String,
      caption:               {type: String, nilable: true},
      video_width:           {type: Int32, nilable: true},
      video_height:          {type: Int32, nilable: true},
      video_duration:        {type: Int32, nilable: true},
      description:           {type: String, nilable: true},
      reply_markup:          {type: InlineKeyboardMarkup, nilable: true},
      input_message_content: {type: InputMessageContent, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
