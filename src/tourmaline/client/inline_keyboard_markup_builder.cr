module Tourmaline
  class Client
    def self.build_inline_keyboard_markup(*args, columns = nil, **options, &block : InlineKeyboardMarkupBuilder ->)
      builder = InlineKeyboardMarkupBuilder.new(*args, **options)
      yield builder
      builder.keyboard(columns)
    end

    def build_inline_keyboard_markup(*args, columns = nil, **options, &block : InlineKeyboardMarkupBuilder ->)
      self.class.build_inline_keyboard_markup(*args, **options, columns: columns, &block)
    end

    class InlineKeyboardMarkupBuilder < KeyboardBuilder(Tourmaline::InlineKeyboardButton, Tourmaline::InlineKeyboardMarkup)
      def keyboard(columns = nil) : G
        buttons = KeyboardBuilder(T, G).build_keyboard(@keyboard, columns: columns || 1)
        InlineKeyboardMarkup.new(inline_keyboard: buttons)
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
