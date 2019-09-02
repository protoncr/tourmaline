require "json"

module Tourmaline::Model
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
