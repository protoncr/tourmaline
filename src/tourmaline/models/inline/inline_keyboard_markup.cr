require "json"

module Tourmaline
  class InlineKeyboardMarkup
    include JSON::Serializable

    property inline_keyboard : Array(Array(InlineKeyboardButton))

    def initialize(@inline_keyboard = [] of Array(InlineKeyboard))
    end

    def initialize(*lines : Array(InlineKeyboardButton))
      @inline_keyboard = Array(Array(InlineKeyboardButton)).new
      @inline_keyboard.concat(lines)
    end

    def <<(row, btn : InlineKeyboardButton)
      inline_keyboard[row] << btn
    end

    def <<(btns : Array(InlineKeyboardButton))
      @inline_keyboard << btns
    end
  end
end
