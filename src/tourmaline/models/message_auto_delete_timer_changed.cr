module Tourmaline
  class MessageAutoDeleteTimerChanged
    include JSON::Serializable
    include Tourmaline::Model

    getter message_auto_delete_time : Int32
  end
end
