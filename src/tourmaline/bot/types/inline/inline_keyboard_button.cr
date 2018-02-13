require "json"

module Tourmaline::Bot
  class InlineKeyboardButton
    FIELDS = {
      text:                String,
      url:                 {type: String, nilable: true},
      callback_data:       {type: String, nilable: true},
      switch_inline_query: {type: String, nilable: true},
    }
    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
