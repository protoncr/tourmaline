require "json"

module Tourmaline
  class UserProfilePhotos
    include JSON::Serializable

    getter total_count : Int32

    getter photos : Array(Array(PhotoSize))
  end
end
