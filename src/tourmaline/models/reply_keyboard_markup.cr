require "json"
require "../keyboard_builder"

module Tourmaline
  alias Button = KeyboardButton | InlineKeyboardButton

  class KeyboardButton
    include JSON::Serializable
    include Tourmaline::Model

    property text : String

    property request_contact : Bool = false

    property request_location : Bool = false

    property request_poll : KeyboardButtonPollType?

    property web_app : WebAppInfo?

    def initialize(@text : String, @request_contact = false, @request_location = false, @request_poll = nil, @web_app = nil)
    end
  end

  # This object represents type of a poll, which is allowed to be
  # created and sent when the corresponding button is pressed.
  class KeyboardButtonPollType
    include JSON::Serializable
    include Tourmaline::Model

    @[JSON::Field(converter: Tourmaline::Poll::PollTypeConverter)]
    property type : Poll::Type

    def initialize(@type)
    end
  end

  class ReplyKeyboardMarkup
    include JSON::Serializable
    include Tourmaline::Model

    property keyboard : Array(Array(KeyboardButton))

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
