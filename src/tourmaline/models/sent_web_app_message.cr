module Tourmaline::Model
  class SentWebAppMessage
    include JSON::Serializable

    getter inline_message_id : String

    def initialize(@inline_message_id : String)
    end
  end
end
