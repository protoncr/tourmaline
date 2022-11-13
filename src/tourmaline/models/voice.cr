module Tourmaline
  class Voice
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter duration : Int32

    getter mime_type : String?

    getter file_size : Int64?
  end
end
