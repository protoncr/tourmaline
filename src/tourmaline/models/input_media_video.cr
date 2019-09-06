require "json"

module Tourmaline::Model
  class InputMediaPhoto
    include JSON::Serializable

    getter type : String

    getter media : String

    getter thumb : (File | String)?

    getter caption : String?

    getter parse_mode : String?

    getter width : Int32?

    getter height : Int32?

    getter duration : Int32?

    getter supports_streaming : Bool?

    def initialize(@type : String, @media : String, @thumb : (File | String)?, @caption : String?, @parse_mode : String?,
                   @width : Int32?, @height : Int32?, duration : Int32?, @supports_streaming : Bool?)
    end
  end
end
