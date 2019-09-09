require "json"

module Tourmaline::Model
  class ShippingQuery
    include JSON::Serializable

    getter id : String

    getter from : User

    getter invoice_payload : String

    getter shipping_address : ShippingAddress

    def initialize(@id : Strig, @from : User, @invoice_payload : String, @shipping_address : ShippingAddress)
    end

    def answer(ok, **kwargs)
      BotContainer.bot.answer_shipping_query(is, ok, **kwargs)
    end
  end
end
