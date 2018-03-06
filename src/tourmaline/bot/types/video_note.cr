require "json"

module Tourmaline::Bot
  class VideoNote
    JSON.mapping(
      file_id: String,
      length: Int32,
      duration: Int32,
      thumb: PhotoSize?,
      file_size: Int32?,
    )
  end
end
