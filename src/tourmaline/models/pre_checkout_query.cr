require "json"

module Tourmaline
  class PreCheckoutQuery
    include JSON::Serializable

    getter id : String

    getter from : User

    getter currency : String

    getter total_amount : Int32

    getter invoice_payload : String

    getter shipping_option_id : String?

    getter order_info : OrderInfo?

    def answer(ok, **kwargs)
      Container.client.answer_pre_checkout_query(id, ok, **kwargs)
    end
  end
end
