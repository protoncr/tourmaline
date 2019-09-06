require "json"

module Tourmaline::Model
  class ChatPhoto
    include JSON::Serializable

    getter small_file_id : String

    getter big_file_id : String
  end
end
