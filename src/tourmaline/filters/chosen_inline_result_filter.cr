module Tourmaline
  # Filters messages containing a chosen inline result, optionally with a specific pattern.
  #
  # Options:
  # - `pattern : (String | Regex)?` - string or regex to match
  #
  # Context additions:
  # - `query : String?` - The query that was matched
  # - `match : Regex::MatchData` - the match data returned by the successful match
  #
  # Example:
  # ```crystal
  # filter = ChosenInlineResultFilter.new(/^foo(\d+)/)
  # ```
  class ChosenInlineResultFilter < Filter
    property pattern : Regex?

    def initialize(pattern : (String | Regex)? = nil)
      case pattern
      when Regex
        @pattern = pattern
      when String
        @pattern = Regex.new("^#{Regex.escape(pattern)}$")
      else
        @pattern = nil
      end
    end

    def exec(client : Client, update : Update) : Bool
      if result = update.chosen_inline_result
        return true unless @pattern
        query = result.query.to_s
        if match = query.match(@pattern.not_nil!)
          update.set_context({ query: query, match: match })
          return true
        end
      end
      false
    end
  end
end
