require "json"

module Tourmaline::Model
  class InputTextMessageContent
    include JSON::Serializable

    getter message_text : String

    getter parse_mode : String?

    getter disable_web_page_preview : Bool?

    def initialize(@message_text : String, @parse_mode : String?, @disable_web_page_preview : Bool?)
    end
  end
end
