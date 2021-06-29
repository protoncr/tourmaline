module Tourmaline
  class BotCommandScopeAllChatAdministrators
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String = "all_chat_administrators"
  end
end
