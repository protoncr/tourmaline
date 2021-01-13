module Tourmaline
  class MaskPosition
    include JSON::Serializable
    include Tourmaline::Model

    getter point : String

    getter x_shift : Float64

    getter y_shift : Float64

    getter scale : Float64

    def initialize(@point : String, @x_shift : Float64, @y_shift : Float64, @scale : Float64)
    end
  end
end
