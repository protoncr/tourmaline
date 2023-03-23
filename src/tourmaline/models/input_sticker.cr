module Tourmaline
  class InputSticker
    include JSON::Serializable

    property sticker : String | File

    property emoji_list : Array(String)

    property mask_position : MaskPosition? = nil

    property keywords : Array(String) = [] of String

    def initialize(@sticker : String | File, @emoji_list : Array(String), @mask_position : MaskPosition? = nil, @keywords : Array(String) = [] of String)
    end
  end
end
