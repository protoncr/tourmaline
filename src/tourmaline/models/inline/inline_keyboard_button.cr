require "json"

module Tourmaline::Model
  class InlineKeyboardButton
    include JSON::Serializable

    getter text : String

    getter url : String?

    getter login_url : LoginURL?

    getter callback_data : String?

    getter switch_inline_query : String?

    getter switch_inline_query_current_chat : String?

    getter callback_game : CallbackGame?

    getter pay : Bool?

    def initialize(@text : String, @url : String?, @login_url : LoginURL? = nil, @callback_data : String? = nil, @switch_inline_query : String? = nil,
      switch_inline_query_current_chat : String? = nil, callback_game : CallbackGame? = nil, pay : Bool? = nil)
    end
  end
end
