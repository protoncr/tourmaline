module Tourmaline
  abstract class Persistence
    abstract def update_user(user : User) : User

    abstract def update_chat(chat : Chat) : Chat

    abstract def user_exists?(user_id : Int) : Bool

    abstract def user_exists?(usename : String) : Bool

    abstract def chat_exists?(chat_id : Int) : Bool

    abstract def chat_exists?(username : String) : Bool

    abstract def get_user(user_id : Int) : User?

    abstract def get_user(username : String) : User?

    abstract def get_chat(chat_id : Int) : Chat?

    abstract def get_chat(username : String) : Chat?

    abstract def handle_persistent_update(update : Update)

    abstract def init
    abstract def cleanup
  end
end

require "./persistence/nil_persistence"
