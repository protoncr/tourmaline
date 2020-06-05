module Tourmaline
  # The default persistence, which is no persistence. This is basically just
  # a placeholder class that does absolutely nothing, but still allows
  # persistence methods to be accessed.
  class NilPersistence < Persistence
    def update_user(user : User) : User
      user
    end

    def update_chat(chat : Chat) : Chat
      chat
    end

    def user_exists?(user_id : Int) : Bool
      false
    end

    def user_exists?(username : String) : Bool
      false
    end

    def chat_exists?(chat_id : Int) : Bool
      false
    end

    def chat_exists?(username : String) : Bool
      false
    end

    def get_user(user_id : Int) : User?
      nil
    end

    def get_user(username : String) : User?
      nil
    end

    def get_chat(chat_id : Int) : Chat?
      nil
    end

    def get_chat(username : String) : Chat?
      nil
    end

    def handle_update(update : Update)
    end

    def init
    end

    def cleanup
    end
  end
end
