require "json"
require "./hash_persistence"

module Tourmaline
  # Persists users and chats in a json file. This isn't the most efficient, but it
  # is easy to set up for testing.
  class JsonPersistence < HashPersistence
    property filename : String

    def initialize(@filename = "tourmaline_persistence.json")
      super
    end

    def init
      if File.file?(@filename)
        json = File.read(@filename)
        parsed = NamedTuple(
          users: Hash(Int64, User),
          user_ids: Hash(String, Int64),
          chats: Hash(Int64, Chat),
          chat_ids: Hash(String, Int64)).from_json(json)
        @persisted_users = parsed[:users]
        @persisted_user_ids = parsed[:user_ids]
        @persisted_chats = parsed[:chats]
        @persisted_chat_ids = parsed[:chat_ids]
      end
    end

    def cleanup
      Log.info { "Persisting data..." }
      json = {
        users:    @persisted_users,
        user_ids: @persisted_user_ids,
        chats:    @persisted_chats,
        chat_ids: @persisted_chat_ids,
      }
      File.write(@filename, json.to_json)
    end
  end
end
