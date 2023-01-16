module Tourmaline::Model
  class MenuButtonWebApp
    include JSON::Serializable

    getter type : String

    getter text : String

    getter web_app : WebAppInfo

    def initialize(@type : String, @text : String, @web_app : WebAppInfo)
    end
  end
end
