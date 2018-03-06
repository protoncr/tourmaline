require "json"

module Tourmaline::Bot
  class ChatPhoto
    JSON.mapping(
      small_file_id: String,
      big_file_id: String,
    )
  end
end
