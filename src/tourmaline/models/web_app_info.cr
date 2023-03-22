module Tourmaline
  class WebAppInfo
    include JSON::Serializable

    getter url : String

    def initialize(@url : String)
    end
  end
end
