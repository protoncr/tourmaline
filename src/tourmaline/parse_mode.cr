module Tourmaline
  # Parse mode for messages.
  enum ParseMode
    None
    Markdown
    MarkdownV2
    HTML

    def self.new(pull : JSON::PullParser)
      case pull.read_string_or_null
      when "Markdown"
        Markdown
      when "MarkdownV2"
        MarkdownV2
      when "HTML"
        HTML
      else
        None
      end
    end

    def to_json(json : JSON::Builder)
      case self
      when None
        json.null
      else
        json.string(to_s)
      end
    end
  end
end
