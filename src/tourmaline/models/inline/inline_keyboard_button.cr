require "json"

module Tourmaline
  class InlineKeyboardButton
    include JSON::Serializable

    property text : String

    property url : String?

    property login_url : LoginURL?

    property callback_data : String?

    property switch_inline_query : String?

    property switch_inline_query_current_chat : String?

    property callback_game : CallbackGame?

    property pay : Bool?

    def initialize(@text : String, @url : String? = nil, @login_url : LoginURL? = nil, @callback_data : String? = nil, @switch_inline_query : String? = nil,
                   switch_inline_query_current_chat : String? = nil, callback_game : CallbackGame? = nil, pay : Bool? = nil)
    end
  end
end
