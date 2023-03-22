module Tourmaline
  class BotCommandScopeDefault
    include JSON::Serializable

    getter type : String = "default"
  end
end
