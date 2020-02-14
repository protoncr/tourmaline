require "json"

module Tourmaline
  class ChatPhoto
    include JSON::Serializable

    getter small_file_id : String

    getter small_file_unique_id : String

    getter big_file_id : String

    getter big_file_unique_id : String
  end
end
