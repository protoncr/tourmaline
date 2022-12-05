module Tourmaline
  class Location
    include JSON::Serializable
    include Tourmaline::Model

    getter longitude : Float64

    getter latitude : Float64

    getter horizontal_accuracy : Float64?

    getter live_period : Int32?

    getter heading : Int32?

    getter proximity_alert_radius : Int32?

    def initialize(@latitude, @longitude, @horizontal_accuracy = nil, @live_period = nil, @heading = nil, @proximity_alert_radius = nil)
    end
  end
end
