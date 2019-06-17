require "json"

module Tourmaline::Bot::Model
  class LabeledPrice
    FIELDS = {
      label:  String,
      amount: Int32,
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
