module Tourmaline
  class BotCommandScopeAllPrivateChats
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String = "all_private_chats"
  end
end
