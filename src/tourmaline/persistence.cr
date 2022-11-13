module Tourmaline
  # Abstract class meant to be a base for other persistence classes.
  # The point of persistence (currently) is to allow Users and Chats
  # to be saved as they're seen, and then provide a way for both
  # to be fetched by either id or username.
  #
  # Example:
  # ```
  # bot = MyBot.new(API_KEY, persistence: Tourmaline::JsonPersistence.new)
  # # ... do some things
  # if user = bot.persistence.get_user?("foobar")
  #   pp user
  # end
  # ```
  #
  abstract class Persistence
    def initialize
      [Signal::INT, Signal::TERM].each do |sig|
        sig.trap do
          cleanup
        end
      end
    end

    # Create or update the provided `User`.
    abstract def update_user(user : User) : User

    # Create or update the provided `Chat`.
    abstract def update_chat(chat : Chat) : Chat

    # Returns true if the user with the provided `user_id` exists.
    abstract def user_exists?(user_id : Int) : Bool

    # Returns true if the user with the provided `username` exists.
    abstract def user_exists?(username : String) : Bool

    # Returns true if the chat with the provided `chat_id` exists.
    abstract def chat_exists?(chat_id : Int) : Bool

    # Returns true if the chat with the provided `username` exists.
    abstract def chat_exists?(username : String) : Bool

    # Fetches a user by `user_id`. Returns `nil` if the user is not found.
    abstract def get_user(user_id : Int) : User?

    # Fetches a user by `username`. Returns `nil` if the user is not found.
    abstract def get_user(username : String) : User?

    # Fetches a chat by `chat_id`. Returns `nil` if the chat is not found.
    abstract def get_chat(chat_id : Int) : Chat?

    # Fetches a chat by `username`. Returns `nil` if the chat is not found.
    abstract def get_chat(username : String) : Chat?

    # Takes an `Update` object, pulls out all unique `Chat`s and `User`s,
    # and uses `update_user` and `update_chat` on each of them respectively.
    abstract def handle_update(update : Update)

    # Gets called when the bot is initialized. This can be used for setup if
    # you need access to the bot instance.
    abstract def init

    # Gets called upon exit. It can be used to perform any necessary cleanup.
    abstract def cleanup
  end
end

require "./persistence/nil_persistence"
