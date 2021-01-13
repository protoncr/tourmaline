module Tourmaline
  class ProximityAlertTriggered
    include JSON::Serializable
    include Tourmaline::Model

    getter traveler : User

    getter watcher : User

    getter distance : Int32
  end
end
