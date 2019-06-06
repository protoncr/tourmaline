require "json"

module Tourmaline::Bot::Model
  class ShippingOption
    FIELDS = {
      id:     String,
      title:  String,
      prices: Array(LabeledPrice),
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
