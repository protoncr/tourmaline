module Tourmaline
  # Parse mode for messages.
  enum ParseMode
    Normal
    Markdown
    MarkdownV2
    HTML

    def self.new(pull : JSON::PullParser)
      parse(pull.read_string_or_null)
    end

    def to_json(json : JSON::Builder)
      case self
      when Normal
        json.null
      else
        json.string(to_s)
      end
    end
  end
end
