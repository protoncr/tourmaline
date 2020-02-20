require "xml"

module Tourmaline
  class Markup
    @keyboard : Array(Array(KeyboardButton))

    @inline_keyboard : Array(Array(InlineKeyboardButton))

    property force_reply : Bool

    property remove_keyboard : Bool

    property selective : Bool

    property resize : Bool

    property one_time : Bool

    def initialize(
      @force_reply = false,
      @remove_keyboard = false,
      @selective = false,
      @keyboard = [] of Array(KeyboardButton),
      @inline_keyboard = [] of Array(InlineKeyboardButton),
      @resize = false,
      @one_time = false
    )
    end

    def buttons(buttons : Array(KeyboardButton | String), columns = nil)
      buttons = buttons.map { |b| b.is_a?(String) ? Markup.button(b) : b }
      keyboard = Markup.build_keyboard(buttons, columns: columns || 1)
      buttons(keyboard)
    end

    def buttons(buttons : Array(Array(KeyboardButton | String)))
      buttons = buttons.map { |b| b.map { |b| b.is_a?(String) ? Markup.button(b) : b } }
      if buttons.size > 0
        @keyboard = buttons
      end
      self
    end

    def keyboard
      ReplyKeyboardMarkup.new(@keyboard, @resize, @one_time, @selective)
    end

    def inline_buttons(buttons : Array(InlineKeyboardButton | String), columns = nil)
      buttons = buttons.map { |b| b.is_a?(String) ? Markup.inline_button(b) : b }
      keyboard = Markup.build_keyboard(buttons, columns: columns || buttons.size)
      inline_buttons(keyboard)
    end

    def inline_buttons(buttons : Array(Array(InlineKeyboardButton | String)))
      buttons = buttons.map { |b| b.map { |b| b.is_a?(String) ? Markup.inline_button(b) : b } }
      if buttons.size > 0
        @inline_keyboard = buttons
      end
      self
    end

    def inline_keyboard
      InlineKeyboardMarkup.new(@inline_keyboard)
    end

    def force_reply(value)
      @force_reply = value
      self
    end

    def remove_keyboard(value)
      @remove_keyboard = value
      self
    end

    def selective(value)
      @selective = value
      self
    end

    def resize(value)
      @resize = value
      self
    end

    def one_time(value)
      @one_time = value
      self
    end

    def button(**opts)
      Markup.button(**opts)
    end

    def inline_button(**opts)
      Markup.inline_button(**opts)
    end

    def contact_request_button(text)
      Markup.contact_request_button(text)
    end

    def location_request_button(text)
      Markup.location_request_button(text)
    end

    def poll_request_button(text, type)
      Markup.poll_request_button(text, type)
    end

    def url_button(text, url)
      Markup.url_button(text, url)
    end

    def callback_button(text, data)
      Markup.callback_button(text, data)
    end

    def switch_to_chat_button(text, value)
      Markup.switch_to_chat_button(text, value)
    end

    def switch_to_current_chat_button(text, value)
      Markup.switch_to_current_chat_button(text, value)
    end

    def game_button(text)
      Markup.game_button(text)
    end

    def pay_button(text)
      Markup.pay_button(text)
    end

    def login_button(text, url, **opts)
      Markup.login_button(text, url, **opts)
    end

    def self.remove_keyboard(value : Bool)
      Markup.new.tap { |k| k.remove_keyboard = true }
    end

    def self.force_reply(value : Bool)
      Markup.new.tap { |k| k.force_reply = true }
    end

    def self.buttons(buttons, **options)
      Markup.new.tap { |k| k.buttons(buttons, **options) }
    end

    def self.inline_buttons(buttons, **options)
      Markup.new.tap { |k| k.inline_buttons(buttons, **options) }
    end

    def self.resize(value : Bool)
      Markup.new.tap { |k| k.resize = true }
    end

    def self.selective(value : Bool)
      Markup.new.tap { |k| k.selective = true }
    end

    def self.one_time(value : Bool)
      Markup.new.tap { |k| k.one_time = true }
    end

    def self.button(text, request_contact = false, request_location = false, request_poll = nil)
      KeyboardButton.new(text, request_contact, request_location, request_poll)
    end

    def self.inline_button(
      text,
      url = nil,
      login_url = nil,
      callback_data = nil,
      switch_inline_query = nil,
      switch_inline_query_current_chat = nil,
      callback_game = nil,
      pay = nil
    )
      InlineKeyboardButton.new(text, url, login_url, callback_data, switch_inline_query,
        switch_inline_query_current_chat, callback_game, pay)
    end

    def self.contact_request_button(text)
      Markup.button(text, request_contact: true)
    end

    def self.location_request_button(text)
      Markup.button(text, request_location: true)
    end

    def self.poll_request_button(text, type : PollType)
      type = KeyboardButtonPollType.new(type)
      Markup.button(text, request_poll: type)
    end

    def self.url_button(text, url)
      Markup.inline_button(text, url: url)
    end

    def self.callback_button(text, data)
      Markup.inline_button(text, callback_data: data)
    end

    def self.switch_to_chat_button(text, value)
      Markup.inline_button(text, switch_inline_query: value)
    end

    def self.switch_to_current_chat_button(text, value)
      Markup.inline_button(text, switch_inline_query_current_chat: value)
    end

    def self.game_button(text)
      Markup.inline_button(text, callback_game: CallbackGame.new)
    end

    def self.pay_button(text)
      Markup.inline_button(text, pay: true)
    end

    def self.login_button(text, url, **opts)
      Markup.inline_button(text, login_url: LoginUrl.new(url, **opts))
    end

    def self.format_html(text = "", entities = [] of MessageEntity)
      available = entities.dup
      opened = [] of MessageEntity
      result = [] of String | Char

      text.chars.each_index do |i|
        loop do
          index = available.index { |e| e.offset == i }
          break if index.nil?
          entity = available[index]

          case entity.type
          when "bold"
            result << "<b>"
          when "italic"
            result << "<i>"
          when "code"
            result << "<code>"
          when "pre"
            if entity.language
              result << "<pre language=\"#{entity.language}\">"
            else
              result << "<pre>"
            end
          when "strikethrough"
            result << "<s>"
          when "underline"
            result << "<u>"
          when "text_mention"
            if user = entity.user
              result << "<a href=\"tg://user?id=#{user.id}\">"
            end
          when "text_link"
            result << "<a href=\"#{entity.url}\">"
          end

          opened.unshift(entity)
          available.delete_at(index)
        end

        result << text[i]

        loop do
          index = opened.index { |e| e.offset + e.length - 1 == i }
          break if index.nil?
          entity = opened[index]

          case entity.type
          when "bold"
            result << "</b>"
          when "italic"
            result << "</i>"
          when "code"
            result << "</code>"
          when "pre"
            result << "</pre>"
          when "strikethrough"
            result << "</s>"
          when "underline"
            result << "</u>"
          when "text_mention"
            if user = entity.user
              result << "</a>"
            end
          when "text_link"
            result << "</a>"
          end

          opened.delete_at(index)
        end
      end

      result.join("")
    end

    def self.build_keyboard(
      buttons : Array(U),
      columns = 1,
      wrap = nil
    ) forall U
      # If `columns` is one or less we don't need to do
      # any hard work
      if columns < 2
        return buttons.map { |b| [b] }
      end

      result = [] of Array(U)
      current_row = [] of U

      wrap_fn = wrap ? wrap : ->(btn : U, index : Int32, current_row : Array(U)) {
        current_row.size >= columns
      }

      buttons.each_with_index do |btn, index|
        if (wrap_fn.call(btn, index, current_row) && current_row.size > 0)
          result << current_row
          current_row.clear
        end

        current_row << btn
      end

      if current_row.size > 0
        result << current_row
      end

      result
    end
  end
end
