module Tourmaline
  class ChatShared
    include JSON::Serializable

    getter request_id : Int32

    getter chat_id : Int64
  end
end
