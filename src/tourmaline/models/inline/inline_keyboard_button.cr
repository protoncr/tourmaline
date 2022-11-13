module Tourmaline
  class InlineKeyboardButton
    include JSON::Serializable
    include Tourmaline::Model

    property text : String

    property url : String?

    property login_url : LoginURL?

    property callback_data : String?

    property web_app : WebAppInfo?

    property switch_inline_query : String?

    property switch_inline_query_current_chat : String?

    property callback_game : CallbackGame?

    property pay : Bool?

    def initialize(@text : String, @url : String? = nil, @login_url : LoginURL? = nil, @callback_data : String? = nil, @web_app = nil, @switch_inline_query : String? = nil, @switch_inline_query_current_chat : String? = nil, @callback_game : CallbackGame? = nil, @pay : Bool? = nil)
    end
  end
end
