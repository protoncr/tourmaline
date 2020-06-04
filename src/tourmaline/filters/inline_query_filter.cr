module Tourmaline
  # Filters messages containing a specfic inline query pattern.
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
  # filter = InlineQueryFilter.new(/^foo(\d+)/)
  # ```
  class InlineQueryFilter < Filter
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
      if inline_query = update.inline_query
        return true unless @pattern
        query = inline_query.query.to_s
        if match = query.match(@pattern.not_nil!)
          update.set_context({ query: query, match: match })
          return true
        end
      end
      false
    end
  end
end
