module Tourmaline
  class InlineQuery
    include JSON::Serializable

    getter id : String

    getter from : User

    getter query : String

    getter offset : String

    getter chat_type : String? # TODO: Make enum

    getter location : Location?
  end
end
