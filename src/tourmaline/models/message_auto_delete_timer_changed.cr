module Tourmaline::Model
  class MessageAutoDeleteTimerChanged
    include JSON::Serializable

    getter message_auto_delete_time : Int32
  end
end
