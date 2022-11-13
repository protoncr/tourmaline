require "html5"

module Tourmaline
  class HTMLParser < BaseParser
    def initialize
      @text = ""
      @entities = [] of MessageEntity
      @building_entities = {} of String => MessageEntity
      @open_tags = Deque(String).new
      @open_tags_meta = Deque(String?).new
    end

    def reset
      @text = ""
      @entities = [] of MessageEntity
      @building_entities = {} of String => MessageEntity
      @open_tags = Deque(String).new
      @open_tags_meta = Deque(String?).new
    end

    def parse(text str : String) : Tuple(String, Array(MessageEntity))
      io = IO::Memory.new(Helpers.pad_utf16(str))
      tokenizer = HTML5::Tokenizer.new(io, "")

      while !tokenizer.next.error?
        token = tokenizer.token
        case token.type
        when .start_tag?
          handle_start_tag(token)
        when .text?
          handle_data(token.data)
        when .end_tag?
          handle_end_tag(token)
        end
      end

      {Helpers.unpad_utf16(@text), @entities}
    ensure
      self.reset
    end

    def unparse(text : String, entities : Array(MessageEntity), _offset = 0, _length = nil) : String
      return text if text.empty? || entities.empty?
      text = Helpers.pad_utf16(text)

      _length = _length || text.size
      html = [] of String
      last_offset = 0

      entities.each_with_index do |entity, i|
        break if entity.offset >= _offset + _length
        relative_offset = entity.offset - _offset
        if relative_offset > last_offset
          html << Helpers.escape_html(text[last_offset...relative_offset])
        elsif relative_offset < last_offset
          next
        end

        skip_entity = false
        length = entity.length

        entity_text = unparse(
          text: text[relative_offset...(relative_offset + length)],
          entities: entities[(i + 1)..],
          _offset: entity.offset,
          _length: length
        )
        entity_type = entity.type

        case entity_type
        when "bold"
          html << "<strong>#{entity_text}</strong>"
        when "italic"
          html << "<em>#{entity_text}</em>"
        when "code"
          html << "<code>#{entity_text}</code>"
        when "underline"
          html << "<u>#{entity_text}</u>"
        when "strikethrough"
          html << "<del>#{entity_text}</del>"
        when "spoiler"
          html << "<tg-spoiler>#{entity_text}</tg-spoiler>"
        when "blockquote"
          html << "<blockquote>#{entity_text}</blockquote>"
        when "pre"
          html << "<pre><code"
          if lang = entity.language
            html << " class=\"language-#{lang}\""
          end
          html << ">#{entity_text}</code></pre>"
        when "email"
          html << "<a href=\"mailto:#{entity_text}\">#{entity_text}</a>"
        when "url"
          html << "<a href=\"#{entity_text}\">#{entity_text}</a>"
        when "text_link"
          html << "<a href=\"#{Helpers.escape_html(entity.url)}\">#{entity_text}</a>"
        when "text_mention"
          html << "<a href=\"tg://user?id=#{entity.user.try(&.id)}\">#{entity_text}</a>"
        else
          skip_entity = true
        end

        last_offset = relative_offset + (skip_entity ? 0 : length)
      end

      html << text[last_offset..]
      Helpers.unpad_utf16(html.join(""))
    end

    private def handle_start_tag(tag : HTML5::Token)
      @open_tags.unshift(tag.data)
      @open_tags_meta.unshift(nil)

      attrs = tag.attr.reduce({} of String => String) do |acc, t|
        acc[t.key] = t.val
        acc
      end

      case tag.data
      when "b", "strong"
        ent_type = "bold"
      when "i", "em"
        ent_type = "italic"
      when "u", "ins"
        ent_type = "underline"
      when "s", "strike", "del"
        ent_type = "strikethrough"
      when "blockquote"
        ent_type = "blockquote"
      when "tg-spoiler"
        ent_type = "spoiler"
      when "code"
        # If we're in the middle of a <pre> tag, this <code> tag is
        # probably intended for syntax highlighting.
        #
        # Syntax highlighting is set with
        #     <code class='language-...'>codeblock</code>
        # inside <pre> tags
        if pre = @building_entities["pre"]?
          if (cls = attrs["class"]?) && (match = cls.match(/\blanguage\-([\w\d\-]+)\b/))
            pre.language = match[1]
          end
        else
          ent_type = "code"
        end
      when "pre"
        ent_type = "pre"
      when "span"
        if (cls = attrs["class"]?) && cls.match(/\btg-spoiler\b/)
          ent_type = "spoiler"
        end
      when "a"
        if href = attrs["href"]?
          if match = href.match(/^tg:\/\/user\?id\=(\d+)/)
            ent_type = "text_mention"
            user = User.new(match[1].to_i64, false, "")
          else
            url = href
            ent_type = "text_link"
          end
        end
      end

      if ent_type && !@building_entities.has_key?(tag.data)
        @building_entities[tag.data] = MessageEntity.new(
          ent_type,
          offset: @text.size,
          url: url,
          user: user,
        )
      end
    end

    private def handle_data(text : String)
      # previous_tag = @open_tags[0]? || ""
      @building_entities.each do |tag, entity|
        entity.length += text.size
      end
      @text += text
    end

    private def handle_end_tag(tag : HTML5::Token)
      begin
        @open_tags.shift
        @open_tags_meta.shift
      rescue ex
      end

      if entity = @building_entities.delete(tag.data)
        @entities.push(entity)
      end
    end
  end
end
