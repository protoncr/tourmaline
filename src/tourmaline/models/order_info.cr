require "json"

module Tourmaline
  class OrderInfo
    include JSON::Serializable

    getter name : String?

    getter phone_number : String?

    getter email : String?

    getter shipping_address : ShippingAddress?
  end
end
