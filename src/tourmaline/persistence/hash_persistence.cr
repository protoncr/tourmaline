require "json"

module Tourmaline
  # Stores all persisted data in memory using a collection of hash tables.
  class HashPersistence < Persistence
    getter filename : String

    getter persisted_users = {} of Int64 => User
    getter persisted_chats = {} of Int64 => Chat
    getter persisted_user_ids = {} of String => Int64
    getter persisted_chat_ids = {} of String => Int64

    def initialize(filename = nil)
      super()
      @filename = filename || "tourmaline_persistence.json"
    end

    def update_user(user : User) : User
      @persisted_users[user.id] = user
      if username = user.username
        @persisted_user_ids[username] = user.id
      end
      user
    end

    def update_chat(chat : Chat) : Chat
      @persisted_chats[chat.id] = chat
      if username = chat.username
        @persisted_chat_ids[username] = chat.id
      end
      chat
    end

    def user_exists?(user_id : Int) : Bool
      !!@persisted_users[user_id.to_i64]?
    end

    def user_exists?(username : String) : Bool
      !!@persisted_user_ids[username]?
    end

    def chat_exists?(chat_id : Int) : Bool
      !!@persisted_chats[chat_id.to_i64]?
    end

    def chat_exists?(username : String) : Bool
      !!@persisted_chat_ids[username]?
    end

    def get_user(user_id : Int) : User?
      @persisted_users[user_id.to_i64]?
    end

    def get_user(username : String) : User?
      if id = @persisted_user_ids[username]?
        @persisted_users[id]?
      end
    end

    def get_chat(chat_id : Int) : Chat?
      @persisted_chats[chat_id.to_i64]?
    end

    def get_chat(username : String) : Chat?
      if id = @persisted_chat_ids[username]?
        @persisted_chats[id]?
      end
    end

    def handle_update(update : Update)
      update.users.each &->update_user(User)
      update.chats.each &->update_chat(Chat)
    end

    def init
    end

    def cleanup
    end
  end
end
