require "json"

module Tourmaline::Bot

  class Location

    JSON.mapping({
      longitude: Float64,
      latitude:  Float64,
    })

  end

end
