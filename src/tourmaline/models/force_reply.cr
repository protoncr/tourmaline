require "json"

module Tourmaline
  class ForceReply
    include JSON::Serializable

    getter force_reply : Bool = true

    getter selective : Bool

    def initialize(@selective : Bool, @force_reply : Bool = true)
    end
  end
end
