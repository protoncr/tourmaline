module Tourmaline
  class VideoNote
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter length : Int32

    getter duration : Int32

    getter thumb : PhotoSize?

    getter file_size : Int32?
  end
end
