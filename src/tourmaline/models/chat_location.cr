module Tourmaline
  class ChatLocation
    include JSON::Serializable
    include Tourmaline::Model

    getter location : Location

    getter address : String
  end
end
