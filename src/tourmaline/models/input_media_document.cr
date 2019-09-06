require "json"

module Tourmaline::Model
  class InputMediaDocument
    include JSON::Serializable

    getter type : String

    getter media : String

    getter thumb : (File | String)?

    getter caption : String?

    getter parse_mode : String?

    def initialize(@type : String, @media : String, @thumb : (File | String)?, @caption : String?, @parse_mode : String?)
    end
  end
end
