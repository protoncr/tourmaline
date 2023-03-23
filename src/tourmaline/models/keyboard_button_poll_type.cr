module Tourmaline
  class KeyboardButtonPollType
    include JSON::Serializable

    property type : String

    def initialize(type : String)
      @type = type
    end
  end
end
