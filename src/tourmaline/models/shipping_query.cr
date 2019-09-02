require "json"

module Tourmaline::Model
  class ShippingQuery
    JSON.mapping(

      id: String,

      from: User,

      invoice_payload: String,

      shipping_address: ShippingAddress
    )
  end
end
