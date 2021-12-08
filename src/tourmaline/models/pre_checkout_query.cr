module Tourmaline
  class PreCheckoutQuery
    include JSON::Serializable
    include Tourmaline::Model

    getter id : String

    getter from : User

    getter currency : String

    getter total_amount : Int32

    getter invoice_payload : String

    getter shipping_option_id : String?

    getter order_info : OrderInfo?

    def answer(ok, **kwargs)
      client.answer_pre_checkout_query(id, ok, **kwargs)
    end
  end
end
