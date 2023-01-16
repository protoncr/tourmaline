module Tourmaline::Model
  class ProximityAlertTriggered
    include JSON::Serializable

    getter traveler : User

    getter watcher : User

    getter distance : Int32
  end
end
