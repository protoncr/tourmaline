module Tourmaline
  class BotCommandScopeDefault
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String = "default"
  end
end
