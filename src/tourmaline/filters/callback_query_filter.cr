module Tourmaline
  # Filters messages containing a callback query, optionally with a specific pattern.
  #
  # Options:
  # - `pattern - A String or Regex which the data must match.
  #
  # Context additions:
  # - `data : String?` - The data that was matched
  # - `match : Regex::MatchData` - the match data returned by the successful match (if it was a Regex)
  #
  # Example:
  # ```crystal
  # filter = CallbackQueryFilter.new(/^foo(\d+)/)
  # ```
  class CallbackQueryFilter < Filter
    property pattern : (String | Regex)?

    def initialize(pattern : (String | Regex)?)
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
        data = callback_query.data.to_s
        if pattern = @pattern
          case pattern
          when String
            if data == pattern
              update.set_context({ data: data })
              return true
            end
          when Regex
            if match = data.to_s.match(pattern)
              update.set_context({ data: data, match: match })
              return true
            end
          else
          end
        else
          update.set_context({ data: data })
          return true
        end
      end
      false
    end
  end
end
