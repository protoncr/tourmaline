module Tourmaline::Model
  class BotCommandScopeDefault
    include JSON::Serializable

    getter type : String = "default"
  end
end
