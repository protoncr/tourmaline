module Tourmaline
  class GameHighScore
    include JSON::Serializable
    include Tourmaline::Model

    getter position : Int32

    getter user : User

    getter score : Int32
  end
end
