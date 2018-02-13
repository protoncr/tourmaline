require "json"

module Tourmaline::Bot

  class Venue

    JSON.mapping(
      location:      Location,
      title:         String,
      address:       String,
      foursquare_id: String?,
    )

  end

end
