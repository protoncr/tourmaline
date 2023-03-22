module Tourmaline
  class BotCommandScopeAllGroupChats
    include JSON::Serializable

    getter type : String = "all_group_chats"
  end
end
