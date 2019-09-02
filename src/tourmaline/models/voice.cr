require "json"

module Tourmaline::Model
  class Voice
    JSON.mapping(
      file_id: String,
      duration: Int32,
      mime_type: String?,
      file_size: Int32?,
    )
  end
end
