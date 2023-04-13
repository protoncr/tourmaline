module Tourmaline
  class Client
    def self.build_reply_keyboard_markup(*args, columns = nil, **options, &block : ReplyKeyboardMarkupBuilder ->)
      builder = ReplyKeyboardMarkupBuilder.new(*args, **options)
      yield builder
      builder.keyboard(columns)
    end

    def build_reply_keyboard_markup(*args, columns = nil, **options, &block : ReplyKeyboardMarkupBuilder ->)
      self.class.build_reply_keyboard_markup(*args, **options, columns: columns, &block)
    end

    class ReplyKeyboardMarkupBuilder < KeyboardBuilder(Tourmaline::KeyboardButton, Tourmaline::ReplyKeyboardMarkup)
      def keyboard(columns = nil) : G
        buttons = KeyboardBuilder(T, G).build_keyboard(@keyboard, columns: columns || 1)
        ReplyKeyboardMarkup.new(
          keyboard: buttons,
          is_persistent: @persistent,
          resize_keyboard: @resize,
          one_time_keyboard: @one_time,
          input_field_placeholder: @input_field_placeholder,
          selective: @selective
        )
      end

      def text_button(text)
        button(text)
      end

      def contact_request_button(text)
        button(text, request_contact: true)
      end

      def location_request_button(text)
        button(text, request_location: true)
      end

      def poll_request_button(text, type)
        type = KeyboardButtonPollType.new(type.to_s)
        button(text, request_poll: type)
      end

      def web_app_button(app : String | WebAppInfo)
        web_app = app.is_a?(String) ? WebAppInfo.new(app) : app
        button(url, web_app: web_app)
      end
    end
  end
end
