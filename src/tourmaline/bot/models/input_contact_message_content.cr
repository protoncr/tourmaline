require "json"
require "./input_message_content.cr"

module Tourmaline::Bot::Model
  class InputContactMessageContent < InputMessageContent
    FIELDS = {
      phone_number: String,
      first_name:   String,
      last_name:    {type: String, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
