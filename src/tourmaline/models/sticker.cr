require "json"

module Tourmaline
  class Sticker
    include JSON::Serializable

    getter file_id : String

    getter file_unique_id : String

    getter width : Int32

    getter height : Int32

    getter thumb : PhotoSize?

    getter emoji : String?

    getter set_name : String?

    getter mask_position : MaskPosition?

    getter file_size : Int32?
  end
end
