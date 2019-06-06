require "json"

module Tourmaline::Bot::Model
  class ShippingAddress
    JSON.mapping(
      country_code: String,
      state: String,
      city: String,
      street_line1: String,
      street_line2: String,
      post_code: String,
    )
  end
end
