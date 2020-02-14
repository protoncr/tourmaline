require "json"

module Tourmaline
  class CallbackQuery
    include JSON::Serializable

    getter id : String

    getter from : User

    getter message : Message?

    getter inline_message_id : String?

    getter chat_instance : String?

    getter data : String?

    getter game_short_name : String?
  end
end
