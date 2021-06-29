module Tourmaline
  class ForceReply
    include JSON::Serializable
    include Tourmaline::Model

    getter force_reply : Bool = true

    getter input_field_placeholder : String? = nil

    getter selective : Bool

    def initialize(@selective : Bool, @force_reply : Bool = true)
    end
  end
end
