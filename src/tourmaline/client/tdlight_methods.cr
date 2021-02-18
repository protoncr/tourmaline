module Tourmaline
  class Client
    module TDLightMethods
      # Remove old data from the in-memory cache and give the freed memory back to the os.
      # Returns true on success.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      def optimize_memory
        res = request(JSON::Any, "optimizeMemory")
        res["result"].as_bool
      end

      # Return a JSON object containing the info about the memory manager, more info
      # [here](https://github.com/tdlight-team/tdlight#tdapigetmemorystatistics).
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      def get_memory_stats
        request(JSON::Any, "getMemoryStats")
      end

      # Return a list of members in the given chat. Raises [ChatNotFound][Tourmaline::Error::ChatNotFound]
      # if your bot is not a member of the requested chat.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      #
      #     Additionally this request is __heavily__ rate limited by Telegram. Use sparingly.
      def get_participants(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        request(Array(ChatMember), "getParticipants", {chat_id: chat_id})
      end

      # Delete all messages from `start_id` to `end_id`. `start_id` must be less than `end_id`
      # and both must be positive, non-zero numbers.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API. This method does not work in private chats
      #     or normal group. It is also not suggested to delete more than 200 messages per call.
      def delete_messages(chat, start_id, end_id)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        res = request(JSON::Any, "deleteMessages", {
          chat_id: chat_id,
          start:   start_id,
          end:     end_id,
        })
        res["result"].as_bool
      end

      # Log in to the server in "user mode". This allows you to log in with your user
      # account instead of a bot account.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      def login(phone_number)
        res = request(JSON::Any, "login", {phone_number: phone_number})
        @user_token = res["token"].as_s
      end

      # Finish authenticating in "user mode" by providing the auth code that Telegram sent you.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      def send_code(code)
        res = request(JSON::Any, "authcode", {code: code.to_i})
        res["authorization_state"].as_s == "ready"
      end

      # Register a user with Telegram. Must be called after `#login` and `#send_code`.
      # Returns true on success.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API. Additionally, user registration is disabled
      #     by default in TDLight. To enable it please see the
      #     [TDLight docs](https://github.com/tdlight-team/tdlight-telegram-bot-api#user-mode).
      def register_user(first_name, last_name = nil)
        res = request(JSON::Any, "registerUser", {
          first_name: first_name,
          last_name:  last_name,
        })
        res["result"].as_bool
      end

      # Send an MTProto ping message to the telegram servers. Useful to
      # detect the delay of the bot api server. Returns the response
      # time in milliseconds.
      #
      # !!! warning
      #     This is a [tdlight](https://github.com/tdlight-team/tdlight-telegram-bot-api) only method.
      #     It **will not work** with the standard bot API.
      def ping
        Int32.new(request(Float64, "ping") * 1000)
      end
    end
  end
end
