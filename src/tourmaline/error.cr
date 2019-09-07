module Tourmaline
  class Error < Exception
    def initialize(message)
      msg = message.sub(/\[?Error\]?: /, "")
      msg = msg.sub("Bad Request: ", "")
      if msg != message
        msg = msg.capitalize
      end
      super(msg)
    end

    class Unauthorized < Error; end

    class InvalidToken < Error
      def initialize
        super("Invalid token")
      end
    end

    class NetworkError < Error; end

    class BadRequest < Error; end

    class TimedOut < Error
      def initialize
        super("Request timed out")
      end
    end

    class ChatMigrated < Error
      def initialize(new_chat_id)
        super("Group migrated to supergroup. New chat id: #{new_chat_id}.")
      end
    end

    class RetryAfter < Error
      def initialize(seconds)
        super("Flood control exceeded. Retry in #{seconds} seconds.")
      end
    end

    class Conflict < Error; end
  end
end
