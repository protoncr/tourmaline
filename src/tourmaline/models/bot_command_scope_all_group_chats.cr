module Tourmaline
  class BotCommandScopeAllGroupChats
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String = "all_group_chats"
  end
end
