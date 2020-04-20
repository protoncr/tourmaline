require "json"
require "../../keyboard_builder"

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

    def self.build(*args, columns = nil, **options)
      builder = Builder.new(*args, **options)
      with builder yield builder
      builder.keyboard(columns)
    end

    class Builder < KeyboardBuilder(Tourmaline::InlineKeyboardButton, Tourmaline::InlineKeyboardMarkup)
      def url_button(text, url)
        button(text, url: url)
      end

      def callback_button(text, data)
        button(text, callback_data: data)
      end

      def switch_to_chat_button(text, value)
        button(text, switch_inline_query: value)
      end

      def switch_to_current_chat_button(text, value)
        button(text, switch_inline_query_current_chat: value)
      end

      def game_button(text)
        button(text, callback_game: CallbackGame.new)
      end

      def pay_button(text)
        button(text, pay: true)
      end

      def login_button(text, url, *args, **opts)
        button(text, login_url: LoginUrl.new(url, *args, **opts))
      end
    end
  end
end
