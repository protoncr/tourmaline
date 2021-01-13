module Tourmaline
  class Venue
    include JSON::Serializable
    include Tourmaline::Model

    getter location : Location

    getter title : String

    getter address : String

    getter foursquare_id : String?

    getter foursquare_type : String?

    getter google_place_id : String?

    getter google_place_type : String?
  end
end
