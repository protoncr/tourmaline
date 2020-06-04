module Tourmaline
  # Filters messages not from users with a specific language_code. Keep in mind
  # that not all Users have a language_code.
  #
  # Options:
  # - `locale : String | Regex` - the language code/pattern to match on
  #
  # Context additions:
  # - `language_code : String` - the matched language code
  #
  # Example:
  # ```crystal
  # filter = LocaleFilter.new(/en|es/)
  # ```
  class LocaleFilter < Filter
    @locale : Regex

    def initialize(locale : String | Regex)
      case locale
      when Regex
        @locale = locale
      when String
        @locale = Regex.new("^#{Regex.escape(locale)}$")
      end
    end

    def exec(client : Client, update : Update) : Bool
      result = false
      update.users do |user|
        if (language_code = user.language_code) && (language_code.match(@locale))
          update.set_context({ language_code: language_code })
          result = true
        end
      end
      result
    end
  end
end
