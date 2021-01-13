module Tourmaline
  class InputVenueMessageContent
    include JSON::Serializable
    include Tourmaline::Model

    getter latitude : Float64

    getter longitude : Float64

    getter title : String

    getter address : String

    getter foursquare_id : String?

    getter foursquare_type : String?

    getter google_place_id : String?

    getter google_place_type : String?

    def initialize(@latitude, @longitude, @title, @address, @foursquare_id = nil, @foursquare_type = nil,
                   @google_place_id = nil, @google_place_type = nil)
    end
  end
end
