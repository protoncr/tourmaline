require "json"

module Tourmaline::Model
  class InlineQuery
    include JSON::Serializable

    getter id : String

    getter from : User

    getter location : Location

    getter query : String

    getter offset : String
  end
end
