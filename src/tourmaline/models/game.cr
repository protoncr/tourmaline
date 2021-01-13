module Tourmaline
  class Game
    include JSON::Serializable
    include Tourmaline::Model

    getter title : String

    getter description : String

    getter photo : Array(PhotoSize)

    getter text : String?

    getter text_entities : Array(MessageEntity)?

    getter animation : Animation?
  end
end
