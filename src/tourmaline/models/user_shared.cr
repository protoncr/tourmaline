module Tourmaline
  class UserShared
    include JSON::Serializable

    getter request_id : Int32

    getter user_id : Int64
  end
end
