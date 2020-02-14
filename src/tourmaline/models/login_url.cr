require "json"

module Tourmaline
  struct LoginURL
    include JSON::Serializable

    getter url : String

    getter forward_text : String?

    getter bot_username : String?

    getter request_write_access : Bool?

    def initialize(@url, @forward_text = nil, @bot_username = nil, @request_write_access = nil)
    end
  end
end
