require "json"

module Tourmaline::Bot::Model
  class MaskPosition
    JSON.mapping(
      point: String,
      x_shift: Float64,
      y_shift: Float64,
      scale: Float64,
    )
  end
end
