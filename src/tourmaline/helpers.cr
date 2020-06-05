module Tourmaline
  module Helpers
    extend self

    DEFAULT_EXTENSIONS = {
      audio:      "mp3",
      photo:      "jpg",
      sticker:    "webp",
      video:      "mp4",
      animation:  "mp4",
      video_note: "mp4",
      voice:      "ogg",
    }

    def format_html(text = "", entities = [] of MessageEntity)
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

    def random_string(length)
      chars = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
      rands = chars.sample(length)
      rands.join
    end
  end
end
