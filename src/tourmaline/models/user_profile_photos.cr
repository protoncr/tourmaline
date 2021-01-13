module Tourmaline
  class UserProfilePhotos
    include JSON::Serializable
    include Tourmaline::Model

    getter total_count : Int32

    getter photos : Array(Array(PhotoSize))
  end
end
