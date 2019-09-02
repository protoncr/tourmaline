require "json"

module Tourmaline::Model
  class Venue
    JSON.mapping(
      location: Location,
      title: String,
      address: String,
      foursquare_id: String?,
    )
  end
end
