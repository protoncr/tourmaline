require "json"

module Tourmaline::Bot::Model
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
