module Tourmaline
  class ShippingAddress
    include JSON::Serializable
    include Tourmaline::Model

    getter country_code : String

    getter state : String

    getter city : String

    getter street_line1 : String

    getter street_line2 : String

    getter post_code : String
  end
end
