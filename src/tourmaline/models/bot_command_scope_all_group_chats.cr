module Tourmaline::Model
  class BotCommandScopeAllGroupChats
    include JSON::Serializable

    getter type : String = "all_group_chats"
  end
end
