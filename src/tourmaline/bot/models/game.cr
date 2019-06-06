require "json"

module Tourmaline::Bot::Model
  class Game
    JSON.mapping(
      title: String,
      description: String,
      photo: Array(PhotoSize),
      text: String?,
      text_entities: Array(MessageEntity)?,
      animation: Animation?,
    )
  end
end
