require "json"
require "./input_message_content.cr"

module Tourmaline::Model
  class InputContactMessageContent
    include JSON::Serializable

    getter phone_number : String

    getter first_name : String

    getter last_name : String?

    getter vcard : String?

    def initialize(@phone_number : String, @first_name : String, @last_name : String?, @vcard : String?)
    end
  end
end
