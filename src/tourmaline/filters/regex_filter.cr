module Tourmaline
  class RegexFilter < Filter
    @expressions : Array(Regex)

    def initialize(*expressions : Regex)
      @expressions = expressions.to_a
    end

    def exec(update : Update) : Bool
      if message = update.message
        @expressions.each do |re|
          return true if re.match(message.text.to_s)
        end
      end
      false
    end
  end
end
