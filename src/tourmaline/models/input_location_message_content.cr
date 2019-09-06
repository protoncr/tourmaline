require "json"

module Tourmaline::Model
  class InputLocationMessageContent
    include JSON::Serializable

    getter latitude : String

    getter longitude : String

    getter live_period : Int32?

    def initialize(@latitude : String, @longitude : String, @live_period : Int32?)
    end
  end
end
