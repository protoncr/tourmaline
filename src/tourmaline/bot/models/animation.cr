require "json"

module Tourmaline::Bot::Model
  class Animation
    JSON.mapping(
      file_id: String,
      thumb: PhotoSize?,
      file_name: String?,
      mime_type: String?,
      file_size: Int32?,
    )
  end
end
