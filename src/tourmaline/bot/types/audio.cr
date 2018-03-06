require "json"

module Tourmaline::Bot
  class Audio
    JSON.mapping(
      file_id: String,
      thumb: PhotoSize?,
      file_name: String?,
      mime_type: String?,
      file_size: Int32?,
    )
  end
end
