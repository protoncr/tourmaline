require "json"

module Tourmaline::Bot::Model
  class UserProfilePhotos
    JSON.mapping(
      total_count: Int32,
      photos: Array(Array(PhotoSize))
    )
  end
end
