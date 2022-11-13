require "json"
require "../../keyboard_builder"

module Tourmaline
  class InlineKeyboardMarkup
    include JSON::Serializable
    include Tourmaline::Model

    property inline_keyboard : Array(Array(InlineKeyboardButton))

    def initialize(@inline_keyboard = [] of Array(InlineKeyboardButton))
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
      def keyboard(columns = nil) : G
        buttons = KeyboardBuilder(T, G).build_keyboard(@keyboard, columns: columns || 1)
        InlineKeyboardMarkup.new(buttons)
      end

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

      def web_app_button(app : String | WebAppInfo)
        web_app = app.is_a?(String) ? WebAppInfo.new(app) : app
        button(url, web_app: web_app)
      end
    end
  end
end
