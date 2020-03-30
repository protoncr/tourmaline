require "json"

module Tourmaline
  class Dice
    include JSON::Serializable

    getter value : Int32
  end
end
