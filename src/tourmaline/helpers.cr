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

    MD_ENTITY_MAP = {
      "bold"          => {"*", "*"},
      "italic"        => {"_", "_"},
      "underline"     => {"", ""},
      "code"          => {"`", "`"},
      "pre"           => {"```\n", "\n```"},
      "pre_language"  => {"```{language}\n", "\n```"},
      "strikethrough" => {"", ""},
      "text_mention"  => {"[", "](tg://user?id={id})"},
      "text_link"     => {"[", "]({url})"},
    }

    MDV2_ENTITY_MAP = {
      "bold"          => {"*", "*"},
      "italic"        => {"_", "_"},
      "underline"     => {"__", "__"},
      "code"          => {"`", "`"},
      "pre"           => {"```\n", "\n```"},
      "pre_language"  => {"```{language}\n", "\n```"},
      "strikethrough" => {"~", "~"},
      "text_mention"  => {"[", "](tg://user?id={id})"},
      "text_link"     => {"[", "]({url})"},
      "spoiler"       => {"||", "||"},
    }

    HTML_ENTITY_MAP = {
      "bold"          => {"<b>", "</b>"},
      "italic"        => {"<i>", "</i>"},
      "underline"     => {"<u>", "</u>"},
      "code"          => {"<code>", "</code>"},
      "pre"           => {"<pre>\n", "\n</pre>"},
      "pre_language"  => {"<pre><code class=\"language-{language}\">\n", "\n</code></pre>"},
      "strikethrough" => {"<s>", "</s>"},
      "text_mention"  => {"<a href=\"tg://user?id={id}\">", "</a>"},
      "text_link"     => {"<a href=\"{url}\">", "</a>"},
      "spoiler"       => {"<span class=\"tg-spoiler\">", "</span>"},
    }

    def unparse_html(text : String, entities ents : Array(MessageEntity))
      pp! text, ents
      parser = HTMLParser.new
      parser.unparse(text, ents)
    end

    def unparse_text(text : String, entities ents : Array(MessageEntity), parse_mode : ParseMode = :markdown, escape : Bool = false)
      if parse_mode == ParseMode::HTML
        return unparse_html(text, ents)
      end

      end_entities = {} of Int32 => Array(MessageEntity)
      start_entities = ents.reduce({} of Int32 => Array(MessageEntity)) do |acc, e|
        acc[e.offset] ||= [] of MessageEntity
        acc[e.offset] << e
        acc
      end

      entity_map = case parse_mode
                   in ParseMode::Markdown
                     MD_ENTITY_MAP
                   in ParseMode::MarkdownV2
                     MDV2_ENTITY_MAP
                   in ParseMode::HTML
                     HTML_ENTITY_MAP
                   end

      text = text.gsub('\u{0}', "") + ' '
      codepoints = text.to_utf16

      io = IO::Memory.new
      io.set_encoding("UTF-16LE")

      codepoints.each_with_index do |codepoint, i|
        if escape && codepoint < 128
          char = codepoint.chr
          case parse_mode
          in ParseMode::HTML
            char = escape_html(char)
          in ParseMode::Markdown
            char = escape_md(char, 1)
          in ParseMode::MarkdownV2
            char = escape_md(char, 2)
          end
        end

        if entities = end_entities[i]?
          # TODO:
          # newline_count = 0
          # loop do
          #   io.seek(-1, :current)
          #   bytes = io.peek
          #   if bytes[0].chr == '\n'
          #     newline_count += 1
          #     io.seek(-1, :current)
          #   else
          #     io.seek(1, :current)
          #     break
          #   end
          # end

          entities.each do |entity|
            if pieces = entity_map[entity.type]?
              io << pieces[1]
                .sub("{language}", entity.language.to_s)
                .sub("{id}", entity.user.try &.id.to_s)
                .sub("{url}", entity.url.to_s)
            end
          end

          # io << ("\n" * newline_count)
          end_entities.delete(i)
        end

        if entities = start_entities[i]?
          entities.each do |entity|
            if pieces = entity_map[entity.type]?
              io << pieces[0]
                .sub("{language}", entity.language.to_s)
                .sub("{id}", entity.user.try &.id.to_s)
                .sub("{url}", entity.url.to_s)

              end_entities[entity.offset + entity.length] ||= [] of MessageEntity
              end_entities[entity.offset + entity.length] << entity
            end
          end
        end

        if char
          io << char
        else
          io.write_bytes(codepoint, IO::ByteFormat::LittleEndian)
        end
      end

      io.rewind.gets_to_end
    end

    def random_string(length)
      chars = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
      rands = chars.sample(length)
      rands.join
    end

    def escape_html(text)
      text.to_s
        .gsub('&', "&amp;")
        .gsub('<', "&lt;")
        .gsub('>', "&gt;")
    end

    def escape_md(text, version = 1)
      text = text.to_s

      case version
      when 0, 1
        chars = ['_', '*', '`', '[', ']', '(', ')']
      when 2
        chars = ['_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!']
      else
        raise "Invalid version #{version} for `escape_md`"
      end

      chars.each do |char|
        text = text.gsub(char, "\\#{char}")
      end

      text
    end

    def pad_utf16(text)
      String.build do |str|
        text.each_char do |c|
          str << c
          if c.ord >= 0x10000 && c.ord <= 0x10FFFF
            str << " "
          end
        end
      end
    end

    def unpad_utf16(text)
      String.build do |str|
        last_char = nil
        text.each_char do |c|
          unless last_char && last_char.ord >= 0x10000 && last_char.ord <= 0x10FFFF
            str << c
          end
          last_char = c
        end
      end
    end
  end
end
