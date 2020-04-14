require "json"
require "./hash_persistence"

module Tourmaline
  module JsonPersistence
    include Persistence
    include HashPersistence

    macro included
      getter filename : String = {{ @type.stringify }}.underscore + ".json"
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
      Log.info { "Persisting data..." }
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
