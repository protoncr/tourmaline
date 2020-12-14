class String
  def to_md(version)
    Tourmaline::Helpers.escape_md(self, version)
  end

  def to_html
    # TODO: Escape HTML entities
    self
  end

  def bold
    Tourmaline::Format::Bold.new(self)
  end

  def italic
    Tourmaline::Format::Italic.new(self)
  end

  def underline
    Tourmaline::Format::Underline.new(self)
  end

  def link(to : String)
    Tourmaline::Format::Link.new(self, to)
  end

  def code
    Tourmaline::Format::Code.new(self)
  end

  def code_block
    Tourmaline::Format::CodeBlock.new(self, language = nil)
  end
end

module Tourmaline
  module Format
    abstract class Token
      abstract def to_md(version : Int32) : String
      abstract def to_html : String
    end

    class Section < Token
      property tokens : Array(Token | String)
      property indent : Int32
      property spacing : Int32

      delegate :push, :<<, :shift, :unshift, to: @tokens

      def initialize(*tokens, @indent : Int32 = 4, @spacing : Int32 = 1)
        @tokens = [] of Token | String
        tokens.each { |t| @tokens << t }
      end

      def to_md(version : Int32 = 2) : String
        title = @tokens.first
        String.build do |str|
          str << title.to_md(version)
          if @tokens.size > 1
            @tokens[1..].each do |tok|
              str << (" " * @indent) + tok.to_md(version)
            end
          end
          str << "\n" * spacing
        end
      end

      def to_html : String
        title = @tokens.first
        String.build do |str|
          str << title.to_html
          if @tokens.size > 1
            @tokens[1..].each do |tok|
              str << (" " * @indent) + tok.to_html
            end
          end
          str << "\n" * spacing
        end
      end
    end

    class SubSection < Section
      def initialize(tokens : Array(Token | String), indent = 8, spacing = 1)
        super(tokens, indent, spacing)
      end
    end

    class SubSubSection < Section
      def initialize(tokens : Array(Token | String), indent = 12, spacing = 1)
        super(tokens, indent, spacing)
      end
    end

    class LineItem < Token
      property tokens : Array(Token | String)
      property spaces : Int32

      delegate :push, :<<, :shift, :unshift, to: @tokens

      def initialize(*tokens, @spaces : Int32 = 1)
        @tokens = [] of Token | String
        tokens.each { |t| @tokens << t }
      end

      def to_md(version : Int32 = 2) : String
        tokens.map(&.to_md(version)).join + ("\n" * spaces)
      end

      def to_html : String
        tokens.map(&.to_html).join + ("\n" * @spaces)
      end
    end

    class KeyValueItem < Token
      property key, value

      def initialize(@key : Token | String, @value : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        key.to_md(version) + ": " + value.to_md(version) + "\n"
      end

      def to_html : String
        key.to_html + ": " + value.to_html + "\n"
      end
    end

    class Bold < Token
      property token

      def initialize(@token : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        "*#{token.to_md(version)}*"
      end

      def to_html : String
        "<b>#{token.to_html}</b>"
      end
    end

    class Italic < Token
      property token

      def initialize(@token : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        "_#{token.to_md(version)}_"
      end

      def to_html : String
        "<i>#{token.to_html}</i>"
      end
    end

    class Underline < Token
      property token

      def initialize(@token : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        raise "Underlines aren't supported in legacy Markdown" unless version == 2
        "__#{token.to_md(version)}__"
      end

      def to_html : String
        "<u>#{token.to_html}</u>"
      end
    end

    class Strikethrough < Token
      property token

      def initialize(@token : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        raise "Strikethroughs aren't supported in legacy Markdown" unless version == 2
        "~#{token.to_md(version)}~"
      end

      def to_html : String
        "<s>#{token.to_html}</s>"
      end
    end

    class Link < Token
      property token
      property url

      def initialize(@token : Token | String, @url : String)
      end

      def to_md(version : Int32 = 2) : String
        "[#{token.to_md(version)}](#{url})"
      end

      def to_html : String
        "<a href=\"#{url}\">#{token.to_html}</a>"
      end
    end

    class Code < Token
      property token

      def initialize(@token : String)
      end

      def to_md(version : Int32 = 2) : String
        "`#{token}`"
      end

      def to_html : String
        "<code>#{token}</code>"
      end
    end

    class CodeBlock < Token
      property token
      property language

      def initialize(@token : String, @language : String? = nil)
      end

      def to_md(version : Int32 = 2) : String
        "```#{language}\n#{token}\n```"
      end

      def to_html : String
        String.build do |str|
          str << "<pre>"
          str << "<code"
          if language
            str << " language = \""
            str << language
            str << "\""
          end
          str << ">"
          str << token
          str << "<\\code>"
          str << "<\\pre>"
        end
      end
    end
  end
end
