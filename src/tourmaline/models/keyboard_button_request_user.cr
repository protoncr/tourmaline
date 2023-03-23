module Tourmaline
  class KeyboardButtonRequestUser
    include JSON::Serializable

    property request_id : Int32

    property user_is_bot : Bool?

    property user_is_premium : Bool?

    def initialize(@request_id : Int32, @user_is_bot : Bool?, @user_is_premium : Bool?)
    end
  end
end
