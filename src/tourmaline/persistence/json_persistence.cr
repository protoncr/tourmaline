require "json"

module Tourmaline
  module JsonPersistence
    include Persistence

    macro included
      getter filename : String = {{ @type.stringify }}.underscore + ".json"
    end

    getter persisted_users = {} of Int64 => User
    getter persisted_chats = {} of Int64 => Chat
    getter persisted_user_ids = {} of String => Int64
    getter persisted_chat_ids = {} of String => Int64

    def save_user(user : User) : User
      @persisted_users[user.id] ||= user
      if username = user.username
        @persisted_user_ids[username] ||= user.id
      end
      user
    end

    def save_chat(chat : Chat) : Chat
      @persisted_chats[chat.id] ||= chat
      if username = chat.username
        @persisted_chat_ids[username] ||= chat.id
      end
      chat
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

    def get_chat(username : String) : User?
      if id = @persisted_chat_ids[username]?
        @persisted_chats[id]?
      end
    end

    def handle_persistent_update(update : Update)
      persisted_users = get_users_from_update(update)
      persisted_chats = get_chats_from_update(update)

      persisted_users.each &->update_user(User)
      persisted_chats.each &->update_chat(Chat)
    end

    def init_p
      if ::File.file?(@filename)
        json = ::File.read(@filename)
        parsed = NamedTuple(
          users: Hash(Int64, User),
          user_ids: Hash(String, Int64),
          chats: Hash(Int64, Chat),
          chat_ids: Hash(String, Int64)
        ).from_json(json)
        @persisted_users = parsed[:users]
        @persisted_user_ids = parsed[:user_ids]
        @persisted_chats = parsed[:chats]
        @persisted_chat_ids = parsed[:chat_ids]
      end
    end

    def cleanup_p
      @@logger.info("Persisting data...")
      json = {
        users: @persisted_users,
        user_ids: @persisted_user_ids,
        chats: @persisted_chats,
        chat_ids: @persisted_chat_ids
      }
      ::File.write(@filename, json.to_json)
    end
  end
end
