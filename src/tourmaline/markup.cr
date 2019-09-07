module Tourmaline
  module Markup
    extend self

    # Creates a reply keyboard using the provided `buttons` and options.
    #
    # If `resize` is true, clients will attempt to resize the keyboard vertically
    # for optimal fit (e.g., make the keyboard smaller if there are just
    # two rows of buttons). Defaults to false.
    #
    # If `one_time` is true, clients will hide the keyboard as soon as it's been used.
    # The keyboard will still be available, but clients will automatically display
    # the usual letter-keyboard in the chat – the user can press a special button
    # in the input field to see the custom keyboard again. Defaults to false.
    #
    # If `selective` is true, the keyboard will be displayed to specific users only.
    # Targets: 1) users that are @mentioned in the text of the Message object;
    # 2) if the bot's message is a reply (has reply_to_message_id), sender
    # of the original message.
    def keyboard(buttons : Array(Array(String | NamedTuple | Model::KeyboardButton)), resize = false, one_time = false, selective = nil)
      buttons = buttons.map do |row|
        row.map do |opts|
          case opts
          when String
            Model::KeyboardButton.new(opts)
          when NamedTuple
            Model::KeyboardButton.new(**opts)
          else
            opts
          end
        end
      end

      Model::ReplyKeyboardMarkup.new(buttons, resize, one_time, selective)
    end

    # Create an inline keyboard using the provided `buttons`.
    def inline_keyboard(buttons : Array(Array(NamedTuple | Model::InlineKeyboardButton)))
      buttons = buttons.map do |row|
        row.map do |opts|
          case opts
          when String
            Model::InlineKeyboardButton.new(opts)
          when NamedTuple
            Model::InlineKeyboardButton.new(**opts)
          else
            opts
          end
        end
      end

      Model::InlineKeyboardMarkup.new(buttons)
    end

    def button(text, request_contact = false, request_location = false)
      Model::KeyboardButton.new(text, request_contact, request_location)
    end

    def location_button(text)
      button(text, false, true)
    end

    def contact_button(text)
      button(text, true, false)
    end

    def inline_button(
      text,
      url = nil,
      login_url = nil,
      callback_data = nil,
      switch_inline_query = nil,
      switch_inline_query_current_chat = nil,
      callback_game = nil,
      pay = nil
    )
      Model::InlineKeyboardButton.new(text, url, login_url, callback_data, switch_inline_query,
      switch_inline_query_current_chat, callback_game, pay)
    end

    def url_button(text, url)
      inline_button(text, url: url)
    end

    def callback_button(text, data)
      inline_button(text, callback: data)
    end

    def switch_to_chat_button(text, value)
      inline_button(text, switch_inline_query: value)
    end

    def switch_to_current_chat_button(text, value)
      inline_button(text, switch_inline_query_current_chat: value)
    end

    def game_button(text)
      inline_button(text, callback_game: Model::CallbackGame.new)
    end

    def pay_button(text)
      inline_button(text, pay: true)
    end

    def login_button(text, url, **opts)
      inline_button(text, login_url: Model::LoginUrl.new(url, **opts))
    end
  end
end
