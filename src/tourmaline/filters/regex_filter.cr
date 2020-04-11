module Tourmaline
  # Filters messages with text (`message.text` | `message.caption`) using a
  # regular expression.
  #
  # Options:
  # - `expressions : *Regex` - regular expressions to match on
  #
  # Context additions:
  # - `match : Regex::MatchData` - the match data returned by the successful match
  #
  # Example:
  # ```crystal
  # filter = RegexFilter.new(/^foo(\d+)/)
  # ```
  class RegexFilter < Filter
    @expressions : Array(Regex)

    def initialize(*expressions : Regex)
      @expressions = expressions.to_a
    end

    def exec(client : Client, update : Update) : Bool
      if message = update.message
        if (text = message.text) || (text = message.caption)
          @expressions.each do |re|
            if match = re.match(message.text.to_s)
              update.set_context({ match: match })
              return true
            end
          end
        end
      end
      false
    end
  end
end
