require "json"

module Tourmaline::Model
  class InlineKeyboardButton
    include JSON::Serializable

    getter text : String

    getter url : String?

    getter callback_data : String?

    getter switch_inline_query : String?

    def initialize(@text : String, @url : String?, @callback_data : String?, @switch_inline_query : String?)
    end
  end
end
