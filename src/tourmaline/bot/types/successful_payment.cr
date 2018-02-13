require "json"

module Tourmaline::Bot

  class SuccessfulPayment

    JSON.mapping(
      currency:                   String,
      total_amount:               Int32,
      invoice_payload:            String,
      shipping_option_id:         String?,
      order_info:                 OrderInfo?,
      telegram_payment_charge_id: String,
      provider_payment_charge_id: String,
    )

  end

end
