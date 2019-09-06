require "json"

module Tourmaline::Model
  class ShippingOption
    include JSON::Serializable

    getter id : String

    getter title : String

    getter prices : Array(LabeledPrice)

    def initialize(@id : String, @title : String, @prices : Array(LabledPrice))
    end
  end
end
