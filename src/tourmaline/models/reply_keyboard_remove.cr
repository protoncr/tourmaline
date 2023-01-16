module Tourmaline::Model
  class ReplyKeyboardRemove
    include JSON::Serializable

    getter remove_keyboard : Bool = true
    getter selective : Bool?

    def initialize(@selective : Bool?, @remove_keyboard : Bool = true)
    end
  end
end
