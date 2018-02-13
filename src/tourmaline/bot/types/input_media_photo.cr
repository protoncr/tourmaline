require "json"

module Tourmaline::Bot

  class InputMediaVideo < InputMedia
    JSON.mapping(
      type:     String,
      media:    String,
      caption:  String?,
      width:    Int32?,
      height:   Int32?,
      duration: Int32?,
    )
  end

end
