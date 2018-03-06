require "json"

module Tourmaline::Bot
  class LabeledPrice
    JSON.mapping(
      label: String,
      amount: Int32,
    )
  end
end
