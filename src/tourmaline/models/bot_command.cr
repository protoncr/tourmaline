module Tourmaline
  class BotCommand
    include JSON::Serializable
    include Tourmaline::Model

    getter command : String

    getter description : String

    def to_h
      {"command" => command, "description" => description}
    end
  end
end
