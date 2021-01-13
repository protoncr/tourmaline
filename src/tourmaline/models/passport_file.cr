module Tourmaline
  class PassportFile
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter file_size : Int64

    @[JSON::Field(converter: Time::EpochConverter)]
    getter file_date : Time?
  end
end
