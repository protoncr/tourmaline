module Tourmaline
  class SentWebAppMessage
    include JSON::Serializable
    include Tourmaline::Model

    getter inline_message_id : String

    def initialize(@inline_message_id : String)
    end
  end
end
