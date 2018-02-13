require "json"

module Tourmaline::Bot

  class ShippingOption

    JSON.mapping(
      id:     String,
      title:  String,
      prices: Array(LabeledPrice),
    )

  end

end
