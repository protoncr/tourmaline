require "json"

module Tourmaline::Model
  class LabeledPrice
    FIELDS = {
      label:  String,
      amount: Int32,
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
