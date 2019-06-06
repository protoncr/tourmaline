require "json"

module Tourmaline::Bot::Model
  class Location
    JSON.mapping({
      longitude: Float64,
      latitude:  Float64,
    })
  end
end
