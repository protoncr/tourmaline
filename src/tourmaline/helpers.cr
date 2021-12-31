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
    }

    def unparse_text(text : String, entities ents : Array(MessageEntity), parse_mode : ParseMode = :markdown, escape : Bool = false)
      start_entities = ents.reduce({} of Int64 => MessageEntity) { |acc, e| acc[e.offset] = e; acc }
      end_entities = ents.reduce({} of Int64 => MessageEntity) { |acc, e| acc[e.offset + e.length] = e; acc }

      chars = text.chars
      chars << ' ' # The last entity doesn't complete without this

      entity_map = case parse_mode
                   when ParseMode::Markdown
                     MD_ENTITY_MAP
                   when ParseMode::MarkdownV2
                     MDV2_ENTITY_MAP
                   when ParseMode::HTML
                     HTML_ENTITY_MAP
                   else
                     raise "Unreachable"
                   end

      String.build do |str|
        chars.each_with_index do |char, i|
          if (entity = start_entities[i]?) && (pieces = entity_map[entity.type]?)
            str << pieces[0]
              .sub("{language}", entity.language.to_s)
              .sub("{id}", entity.user.try &.id.to_s)
              .sub("{url}", entity.url.to_s)
          elsif (entity = end_entities[i]?) && (pieces = entity_map[entity.type]?)
            str << pieces[1]
              .sub("{language}", entity.language.to_s)
              .sub("{id}", entity.user.try &.id.to_s)
              .sub("{url}", entity.url.to_s)
          end

          if escape
            case parse_mode
            in ParseMode::HTML
              char = escape_html(char)
            in ParseMode::Markdown
              char = escape_md(char, 1)
            in ParseMode::MarkdownV2
              char = escape_md(char, 2)
            end
          end

          str << char unless (i == chars.size - 1)
        end
      end
    end

    def random_string(length)
      chars = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
      rands = chars.sample(length)
      rands.join
    end

    def escape_html(text)
      text.to_s
        .gsub('<', "&lt;")
        .gsub('>', "&gt;")
        .gsub('&', "&amp;")
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
  end
end
