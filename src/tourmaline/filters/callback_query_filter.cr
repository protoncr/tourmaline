module Tourmaline
  # Filters messages containing a callback query, optionally with a specific pattern.
  #
  # Options:
  # - `pattern : (String | Regex)?` - string or regex to match
  #
  # Context additions:
  # - `data : String?` - The data that was matched
  # - `match : Regex::MatchData` - the match data returned by the successful match
  #
  # Example:
  # ```crystal
  # filter = CallbackQueryFilter.new(/^foo(\d+)/)
  # ```
  class CallbackQueryFilter < Filter
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
      if callback_query = update.callback_query
        return true unless @pattern
        data = callback_query.data.to_s
        if match = data.match(@pattern.not_nil!)
          update.set_context({ data: data, match: match })
          return true
        end
      end
      false
    end
  end
end
