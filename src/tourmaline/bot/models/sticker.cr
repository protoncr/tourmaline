require "json"

module Tourmaline::Bot::Model
  class Sticker
    JSON.mapping(
      file_id: String,
      width: Int32,
      height: Int32,
      thumb: PhotoSize?,
      emoji: String?,
      set_name: String?,
      mask_position: MaskPosition?,
      file_size: Int32?,
    )
  end
end
