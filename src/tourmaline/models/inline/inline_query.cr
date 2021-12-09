module Tourmaline
  class InlineQuery
    include JSON::Serializable
    include Tourmaline::Model

    getter id : String

    getter from : User

    getter query : String

    getter offset : String

    getter chat_type : String? # TODO: Make enum

    getter location : Location?

    def answer(results, **kwargs)
      client.answer_inline_query(id, results, **kwargs)
    end
  end
end
