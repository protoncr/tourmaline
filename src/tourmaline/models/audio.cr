module Tourmaline
  class Audio
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter duration : Int32

    getter performer : String?

    getter title : String?

    getter file_name : String?

    getter mime_type : String?

    getter file_size : Int64?

    getter thumb : PhotoSize?
  end
end
