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

    def initialize(@keyboard : Array(Array(KeyboardButton)), @resize_keyboard : Bool? = nil, @one_time_keyboard : Bool? = nil, @selective : Bool? = nil)
    end

    def <<(row : Int32, key : KeyboardButton)
      keyboard[row] << key
    end

    def <<(keys : Array(KeyboardButton))
      keyboard << keys
    end

    def swap_row(row : Int32, keys : Array(KeyboardButton))
      keyboard[row] = keys
    end

    def delete_row(row)
      keyboard[row].delete
    end
  end
end
