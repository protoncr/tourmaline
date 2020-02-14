require "json"

module Tourmaline
  class WebhookInfo
    include JSON::Serializable

    getter url : String

    getter has_custom_certificate : Bool

    getter pending_update_count : Int32

    @[JSON::Field(converter: Time::EpochMillisConverter)]
    getter last_error_date : Time?

    getter last_error_message : String?

    getter max_connections : Int32?

    getter allowed_updates : Array(String)?
  end
end
