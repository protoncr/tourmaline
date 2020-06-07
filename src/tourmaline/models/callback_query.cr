module Tourmaline
  class CallbackQuery
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    private property! client : Tourmaline::Client

    getter id : String

    getter from : User

    getter message : Message?

    getter inline_message_id : String?

    getter chat_instance : String?

    getter data : String?

    getter game_short_name : String?

    def answer(*args, **kwargs)
      client.answer_callback_query(id, *args, **kwargs)
    end
  end
end
