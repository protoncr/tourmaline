module Tourmaline
  class OrderInfo
    include JSON::Serializable
    include Tourmaline::Model

    getter name : String?

    getter phone_number : String?

    getter email : String?

    getter shipping_address : ShippingAddress?
  end
end
