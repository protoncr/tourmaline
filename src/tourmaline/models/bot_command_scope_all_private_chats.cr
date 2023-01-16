module Tourmaline::Model
  class BotCommandScopeAllPrivateChats
    include JSON::Serializable

    getter type : String = "all_private_chats"
  end
end
