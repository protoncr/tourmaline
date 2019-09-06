require "json"

module Tourmaline::Model
  class Invoice
    include JSON::Serializable

    getter title : String

    getter description : String

    getter start_parameter : String

    getter currency : String

    getter total_amount : Int32
  end
end
