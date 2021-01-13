module Tourmaline
  class PhotoSize
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter width : Int32

    getter height : Int32

    getter file_size : Int64
  end
end
