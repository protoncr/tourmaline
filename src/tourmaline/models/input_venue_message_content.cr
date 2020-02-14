require "json"

module Tourmaline
  class InputVenueMessageContent
    include JSON::Serializable

    getter latitude : Float64

    getter longitude : Float64

    getter title : String

    getter address : String

    getter foursquare_id : String?

    getter foursquare_type : String?

    def initialize(@latitude : Float64, @longitude : Float64, @title : String, @address : String,
                   @foursquare_id : String? = nil, @foursquare_type : String? = nil)
    end
  end
end
