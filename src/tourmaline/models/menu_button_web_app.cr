module Tourmaline
  class MenuButtonWebApp
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String

    getter text : String

    getter web_app : WebAppInfo

    def initialize(@type : String, @text : String, @web_app : WebAppInfo)
    end
  end
end
