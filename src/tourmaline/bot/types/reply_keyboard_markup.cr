require "json"

module Tourmaline::Bot
  class KeyboardButton
    FIELDS = {
      text:             {type: String, nilable: false},
      request_contact:  {type: Bool, nilable: true},
      request_location: {type: Bool, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end

  class ReplyKeyboardMarkup
    FIELDS = {
      keyboard:          Array(Array(KeyboardButton)),
      resize_keyboard:   {type: Bool, nilable: true},
      one_time_keyboard: {type: Bool, nilable: true},
      selective:         {type: Bool, nilable: true},
    }

    JSON.mapping({{FIELDS}})

    initializer_for({{FIELDS}})

    # Alternative constructor that allows to build markup object with text-only buttons
    def initialize(keyboard : Array(Array(String)), resize_keyboard : Bool? = nil, one_time_keyboard : Bool? = nil, selective : Bool? = nil)
      buttons = keyboard.map { |row| row.map { |text| KeyboardButton.new(text) } }
      initialize(buttons, resize_keyboard, one_time_keyboard, selective)
    end
  end
end
