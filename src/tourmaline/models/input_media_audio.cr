require "json"

module Tourmaline::Model
  class InputMediaAudio
    include JSON::Serializable

    getter type : String

    getter media : String

    getter thumb : (File | String)?

    getter caption : String?

    getter parse_mode : String?

    getter duration : Int32?

    getter performer : String?

    getter title : String?

    def initialize(@type : String, @media : String, @thumb : (File | String)? = nil, @caption : String? = nil, @parse_mode : String? = nil,
                   duration : Int32? = nil, @performer : String? = nil, @title : String? = nil)
    end
  end
end
