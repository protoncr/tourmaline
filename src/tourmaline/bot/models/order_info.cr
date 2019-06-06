require "json"

module Tourmaline::Bot::Model
  class OrderInfo
    JSON.mapping(
      name: String?,
      phone_number: String?,
      email: String?,
      shipping_address: ShippingAddress?,
    )
  end
end
