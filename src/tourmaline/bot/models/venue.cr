require "json"

module Tourmaline::Bot::Model
  class Venue
    JSON.mapping(
      location: Location,
      title: String,
      address: String,
      foursquare_id: String?,
    )
  end
end
