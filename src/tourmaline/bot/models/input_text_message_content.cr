require "json"

module Tourmaline::Bot::Model
  class InputTextMessageContent < InputMessageContent
    FIELDS = {
      message_text:             String,
      parse_mode:               {type: String, nilable: true},
      disable_web_page_preview: {type: Bool, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
