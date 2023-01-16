module Tourmaline::Model
  class WebAppInfo
    include JSON::Serializable

    getter url : String

    def initialize(@url : String)
    end
  end
end
