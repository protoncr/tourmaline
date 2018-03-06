require "json"

module Tourmaline::Bot
  class Invoice
    JSON.mapping(
      title: String,
      description: String,
      start_parameter: String,
      currency: String,
      total_amount: Int32,
    )
  end
end
