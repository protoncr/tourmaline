module Tourmaline
  class BotCommandScopeAllChatAdministrators
    include JSON::Serializable

    getter type : String = "all_chat_administrators"
  end
end
