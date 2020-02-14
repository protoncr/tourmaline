require "json"

module Tourmaline
  class Contact
    include JSON::Serializable

    getter phone_number : String

    getter first_name : String

    getter last_name : String?

    getter user_id : Int32?
  end
end
