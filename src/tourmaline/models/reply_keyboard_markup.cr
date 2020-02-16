require "json"

module Tourmaline
  alias Button = KeyboardButton | InlineKeyboardButton

  class KeyboardButton
    include JSON::Serializable

    getter text : String

    getter request_contact : Bool = false

    getter request_location : Bool = false

    getter request_poll : KeyboardButtonPollType?

    def initialize(@text : String, @request_contact = false, @request_location = false, @request_poll = nil)
    end
  end

  # This object represents type of a poll, which is allowed to be
  # created and sent when the corresponding button is pressed.
  class KeyboardButtonPollType
    include JSON::Serializable

    @[JSON::Field(converter: Tourmaline::Poll::PollTypeConverter)]
    getter type : PollType

    def initialize(@type)
    end
  end

  class ReplyKeyboardMarkup
    include JSON::Serializable

    getter keyboard : Array(Array(KeyboardButton))

    getter resize_keyboard : Bool = false

    getter one_time_keyboard : Bool = false

    getter selective : Bool = false

    def initialize(@keyboard = [] of Array(KeyboardButton), @resize_keyboard = false, @one_time_keyboard = false, @selective = false)
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

    def size
      keyboard.size
    end
  end
end
