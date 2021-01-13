module Tourmaline
  class ChatPhoto
    include JSON::Serializable
    include Tourmaline::Model

    getter small_file_id : String

    getter small_file_unique_id : String

    getter big_file_id : String

    getter big_file_unique_id : String
  end
end
