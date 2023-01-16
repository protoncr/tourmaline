module Tourmaline::Model
  class Dice
    include JSON::Serializable

    getter emoji : String
    getter value : Int32
  end
end
