require "json"

module Tourmaline::Bot::Model
  class WebhookInfo
    JSON.mapping(
      url: String,
      has_custom_certificate: Bool,
      pending_update_count: Int32,
      last_error_date: {type: Time, converter: Time::EpochMillisConverter, nilable: true},
      last_error_message: String?,
      max_connections: Int32?,
      allowed_updates: Array(String)?
    )
  end
end
