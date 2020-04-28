require "xml"

module Tourmaline
  class KeyboardBuilder(T, G)
    property force_reply : Bool

    property remove_keyboard : Bool

    property selective : Bool

    property resize : Bool

    property one_time : Bool

    def initialize(
      @force_reply = false,
      @remove_keyboard = false,
      @selective = false,
      @keyboard = [] of T,
      @resize = false,
      @one_time = false
    )
    end

    def keyboard(columns = nil)
      buttons = KeyboardBuilder(T, G).build_keyboard(@keyboard, columns: columns || 1)
      G.new(buttons, @resize, @one_time, @selective)
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

    def self.remove_keyboard(value : Bool)
      self.new.tap { |k| k.remove_keyboard = true }
    end

    def self.force_reply(value : Bool)
      self.new.tap { |k| k.force_reply = true }
    end

    def self.buttons(buttons, **options)
      self.new.tap { |k| k.buttons(buttons, **options) }
    end

    def self.inline_buttons(buttons, **options)
      self.new.tap { |k| k.inline_buttons(buttons, **options) }
    end

    def self.resize(value : Bool)
      self.new.tap { |k| k.resize = true }
    end

    def self.selective(value : Bool)
      self.new.tap { |k| k.selective = true }
    end

    def self.one_time(value : Bool)
      self.new.tap { |k| k.one_time = true }
    end

    def button(*args, **options)
      @keyboard << T.new(*args, **options)
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
            if entity.user
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
      buttons : Array(T),
      columns = 1,
      wrap = nil
    )
      # If `columns` is one or less we don't need to do
      # any hard work
      if columns < 2
        return buttons.map { |b| [b] }
      end

      wrap_fn = wrap ? wrap : ->(_btn : T, _index : Int32, current_row : Array(T)) {
        current_row.size >= columns
      }

      result = [] of Array(T)
      current_row = [] of T

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
