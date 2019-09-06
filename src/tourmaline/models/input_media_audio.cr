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

    def initialize(@type : String, @media : String, @thumb : (File | String)?, @caption : String?, @parse_mode : String?,
                   duration : Int32?, @performer : String?, @title : String?)
    end
  end
end
