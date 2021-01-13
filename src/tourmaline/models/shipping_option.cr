module Tourmaline
  class ShippingOption
    include JSON::Serializable
    include Tourmaline::Model

    getter id : String

    getter title : String

    getter prices : Array(LabeledPrice)

    def initialize(@id : String, @title : String, @prices : Array(LabeledPrice))
    end
  end
end
