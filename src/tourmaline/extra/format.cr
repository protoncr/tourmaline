require "../helpers"

class String
  # Escape the markdown in this string
  def to_md(version = 2)
    Tourmaline::Helpers.escape_md(self, version)
  end

  # Escspe the HTML in this string
  def to_html
    Tourmaline::Helpers.escape_html(self)
  end

  # Convert the string to a `Tourmaline::Format::Bold`
  def bold
    Tourmaline::Format::Bold.new(self)
  end

  # Convert the string to a `Tourmaline::Format::Italic`
  def italic
    Tourmaline::Format::Italic.new(self)
  end

  # Convert the string to a `Tourmaline::Format::Underline`
  def underline
    Tourmaline::Format::Underline.new(self)
  end

  # Convert the string to a `Tourmaline::Format::Link`
  def link(to : String)
    Tourmaline::Format::Link.new(self, to)
  end

  # Convert the string to a `Tourmaline::Format::Code`
  def code
    Tourmaline::Format::Code.new(self)
  end

  # Convert the string to a `Tourmaline::Format::CodeBlock`
  def code_block
    Tourmaline::Format::CodeBlock.new(self, language: nil)
  end
end

module Tourmaline
  # The `Tourmaline::Format` module provides an easy to use DSL for
  # formatting text for Telegram. It takes care of escaping
  # entities for you so you don't have to.
  #
  # Heavily inspired by the [mdtex](https://github.com/kantek/kantek/blob/master/kantek/utils/mdtex.py)
  # module from Kantek, so thanks Simon!
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

      def self.build(*args, **kwargs, &block : self ->)
        section = new(*args, **kwargs)
        yield section
        section
      end

      def to_md(version : Int32 = 2) : String
        title = @tokens.first
        String.build do |str|
          str << title.to_md(version) + "\n"
          if @tokens.size > 1
            str << @tokens[1..].map do |tok|
              (" " * @indent) + tok.to_md(version)
            end.join('\n')
          end
          str << "\n" * spacing
        end
      end

      def to_html : String
        title = @tokens.first
        String.build do |str|
          str << title.to_html + "\n"
          if @tokens.size > 1
            str << @tokens[1..].map do |tok|
              (" " * @indent) + tok.to_html
            end.join('\n')
          end
          str << "\n" * spacing
        end
      end

      # :nodoc:
      def self.block_section
        Section.fibers[Fiber.current]?
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

    class Group < Token
      property tokens : Array(Token | String)

      delegate :push, :<<, :shift, :unshift, to: @tokens

      def initialize(*tokens)
        @tokens = [] of Token | String
        tokens.each { |t| @tokens << t }
      end

      def build(*args, **kwargs, &block : self ->)
        group = new(*args, **kwargs)
        yield group
        group
      end

      def to_md(version : Int32 = 2) : String
        tokens.map(&.to_md(version)).join
      end

      def to_html : String
        tokens.map(&.to_html).join
      end
    end

    class LineItem < Group
      property tokens : Array(Token | String)
      property spaces : Int32

      delegate :push, :<<, :shift, :unshift, to: @tokens

      def initialize(*tokens, @spaces : Int32 = 1)
        super(*tokens)
      end

      def to_md(version : Int32 = 2) : String
        super(version) + ("\n" * spaces)
      end

      def to_html : String
        super + ("\n" * @spaces)
      end
    end

    class KeyValueItem < Token
      property key, value

      def initialize(@key : Token | String, @value : Token | String)
      end

      def to_md(version : Int32 = 2) : String
        key.to_md(version) + ": " + value.to_md(version)
      end

      def to_html : String
        key.to_html + ": " + value.to_html
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

    class UserMention < Token
      property token
      property user_id

      def initialize(@token : Token | String, @user_id : Int64)
      end

      def self.new(user)
        UserMention.new(user.full_name, user.id.not_nil!)
      end

      def to_md(version : Int32 = 2) : String
        "[#{token.to_md(version)}](tg://user?id=#{user_id})"
      end

      def to_html : String
        "<a href=\"tg://user?id=#{user_id}\">#{token.to_html}</a>"
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
