module Tourmaline
  abstract class Controller
    abstract def execute

    def api
      ADI.container.telegram_telegram_service
    end

    def description
      nil
    end

    def usage
      nil
    end

    def examples
      [] of String
    end

    def help_text
      String.build do |str|
        str << "*#{self.class.name.split("::").last}*\n\n"

        if description
          str << "#{description}\n\n"
        end

        if usage
          str << "*Usage:*\n"
          str << "`#{usage}`\n\n"
        end

        if examples.any?
          str << "*Examples:*\n"
          examples.each do |example|
            str << "`#{example}`\n"
          end
          str << "\n"
        end
      end
    end
  end
end

require "./controllers/*"
