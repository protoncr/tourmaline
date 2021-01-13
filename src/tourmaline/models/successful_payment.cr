module Tourmaline
  class SuccessfulPayment
    include JSON::Serializable
    include Tourmaline::Model

    getter currency : String

    getter total_amount : Int32

    getter invoice_payload : String

    getter shipping_option_id : String?

    getter order_info : OrderInfo?

    getter telegram_payment_charge_id : String

    getter provider_payment_charge_id : String
  end
end
