require "json"

module Tourmaline
  class Venue
    include JSON::Serializable

    getter location : Location

    getter title : String

    getter address : String

    getter foursquare_id : String?
  end
end
