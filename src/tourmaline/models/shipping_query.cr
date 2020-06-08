module Tourmaline
  class ShippingQuery
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    property! client : Tourmaline::Client

    getter id : String

    getter from : User

    getter invoice_payload : String

    getter shipping_address : ShippingAddress

    def initialize(@id : Strig, @from : User, @invoice_payload : String, @shipping_address : ShippingAddress)
    end

    def answer(ok, **kwargs)
      Container.client.answer_shipping_query(id, ok, **kwargs)
    end
  end
end
