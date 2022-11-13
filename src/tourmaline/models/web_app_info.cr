module Tourmaline
  class WebAppInfo
    include JSON::Serializable
    include Tourmaline::Model

    getter url : String

    def initialize(@url : String)
    end
  end
end
