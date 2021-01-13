module Tourmaline
  class Dice
    include JSON::Serializable
    include Tourmaline::Model

    getter emoji : String
    getter value : Int32
  end
end
