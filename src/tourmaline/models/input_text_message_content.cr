require "json"

module Tourmaline
  class InputTextMessageContent
    include JSON::Serializable

    getter message_text : String

    getter parse_mode : String?

    getter disable_web_page_preview : Bool?

    def initialize(@message_text : String, @parse_mode : String? = nil, @disable_web_page_preview : Bool? = nil)
    end
  end
end
