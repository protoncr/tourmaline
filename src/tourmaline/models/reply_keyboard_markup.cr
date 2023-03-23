require "json"
require "../keyboard_builder"

module Tourmaline
  class ReplyKeyboardMarkup
    include JSON::Serializable

    property keyboard : Array(Array(KeyboardButton))

    property is_persistent : Bool = false

    property resize_keyboard : Bool = false

    property one_time_keyboard : Bool = false

    property input_field_placeholder : String? = nil

    property selective : Bool = false

    def initialize(@keyboard = [] of Array(KeyboardButton), @resize_keyboard = false, @one_time_keyboard = false, @input_field_placeholder = nil, @selective = false)
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

    def self.build(*args, columns = nil, **options)
      builder = Builder.new(*args, **options)
      with builder yield builder
      builder.keyboard(columns)
    end

    class Builder < KeyboardBuilder(Tourmaline::KeyboardButton, Tourmaline::ReplyKeyboardMarkup)
      def keyboard(columns = nil) : G
        buttons = KeyboardBuilder(T, G).build_keyboard(@keyboard, columns: columns || 1)
        ReplyKeyboardMarkup.new(buttons, @resize, @one_time, @input_field_placeholder, @selective)
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

      def poll_request_button(text, type : Poll::Type)
        type = KeyboardButtonPollType.new(type)
        button(text, request_poll: type)
      end

      def web_app_button(app : String | WebAppInfo)
        web_app = app.is_a?(String) ? WebAppInfo.new(app) : app
        button(url, web_app: web_app)
      end
    end
  end
end
