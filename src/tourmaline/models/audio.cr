module Tourmaline
  class Audio
    include JSON::Serializable

    getter file_id : String

    getter file_unique_id : String

    getter duration : Int32

    getter performer : String?

    getter title : String?

    getter file_name : String?

    getter mime_type : String?

    getter file_size : Int64?

    getter thumbnail : PhotoSize?
  end
end
