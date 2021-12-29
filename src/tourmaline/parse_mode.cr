module Tourmaline
  # Parse mode for messages.
  enum ParseMode
    Markdown
    MarkdownV2
    HTML

    def self.new(pull : JSON::PullParser)
      parse(pull.read_string_or_null)
    end

    def to_json(json : JSON::Builder)
      json.string(to_s)
    end
  end
end
