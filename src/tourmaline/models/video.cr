require "json"

module Tourmaline::Model
  class Video
    JSON.mapping(
      file_id: String,
      width: Int32,
      height: Int32,
      duration: Int32,
      thumb: PhotoSize?,
      mime_type: String?,
      file_size: Int32?,
    )
  end
end
