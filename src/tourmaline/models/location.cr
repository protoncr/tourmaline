require "json"

module Tourmaline
  class Location
    include JSON::Serializable

    getter longitude : Float64

    getter latitude : Float64

    def initialize(@latitude : Float64, @longitude : Float64)
    end
  end
end
