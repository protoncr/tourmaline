module Tourmaline
  class InputLocationMessageContent
    include JSON::Serializable
    include Tourmaline::Model

    getter latitude : String

    getter longitude : String

    getter horizontal_accuracy : Int32?

    getter live_period : Int32?

    getter heading : Int32?

    getter proximity_alert_radius : Int32?

    def initialize(@latitude, @longitude, @horizontal_accuracy = nil, @live_period = nil, @heading = nil, @proximity_alert_radius = nil)
    end
  end
end
