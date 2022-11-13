module Tourmaline
  class MenuButtonCommands
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String

    def initialize(@type : String)
    end
  end
end
