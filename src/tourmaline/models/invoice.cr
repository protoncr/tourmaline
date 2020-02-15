require "json"

module Tourmaline
  class Invoice
    include JSON::Serializable

    getter title : String

    getter description : String

    getter start_parameter : String

    getter currency : String

    getter total_amount : Int32

    def initialize(@title, @description, @start_parameter, @currency, @total_amount)
    end
  end
end
