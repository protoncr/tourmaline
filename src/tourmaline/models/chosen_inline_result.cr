module Tourmaline
  class ChosenInlineResult
    include JSON::Serializable
    include Tourmaline::Model

    getter result_id : String

    getter from : User

    getter location : Location?

    getter inline_message_id : String?

    getter query : String
  end
end
