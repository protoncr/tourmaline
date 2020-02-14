require "json"

module Tourmaline
  class LabeledPrice
    include JSON::Serializable

    getter label : String

    getter amount : Int32

    def initialize(@label : String, @amount : Int32)
    end
  end
end
