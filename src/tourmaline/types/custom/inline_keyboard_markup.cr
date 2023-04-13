module Tourmaline
  class InlineKeyboardMarkup
    def <<(row, btn : InlineKeyboardButton)
      inline_keyboard[row] << btn
    end

    def <<(btns : Array(InlineKeyboardButton))
      @inline_keyboard << btns
    end
  end
end
