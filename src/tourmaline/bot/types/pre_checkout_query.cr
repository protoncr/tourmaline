require "json"

module Tourmaline::Bot

  class PreCheckoutQuery

    JSON.mapping(
      id:                 String,
      from:               User,
      currency:           String,
      total_amount:       Int32,
      invoice_payload:    String,
      shipping_option_id: String?,
      # order_info:         OrderInfo?,
    )

  end

end
