require "json"

module Tourmaline::Model
  class KeyboardButton
    include JSON::Serializable

    getter text : String

    getter request_contact : Bool?

    getter request_location : Bool?

    def initialize(@text : String, @request_contact : Bool? = nil, @request_location : Bool? = nil)
    end
  end

  class ReplyKeyboardMarkup
    include JSON::Serializable

    getter keyboard : Array(Array(KeyboardButton))

    getter resize_keyboard : Bool?

    getter one_time_keyboard : Bool?

    getter selective : Bool?

    def initialize(keyboard : Array(Array(String | KeyboardButton)), @resize_keyboard : Bool? = nil, @one_time_keyboard : Bool? = nil, @selective : Bool? = nil)
      @keyboard = keyboard.map { |row| row.map { |text| text.is_a?(String) ? KeyboardButton.new(text) : text } }
    end
  end
end
