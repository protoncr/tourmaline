require "json"

module Tourmaline
  class GameHighScore
    include JSON::Serializable

    getter position : Int32

    getter user : User

    getter score : Int32
  end
end
