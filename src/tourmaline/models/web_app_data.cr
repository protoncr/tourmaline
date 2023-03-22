module Tourmaline
  class WebAppData
    include JSON::Serializable

    getter data : String

    getter button_text : String

    def initialize(@data : String, @button_text : String)
    end
  end
end
