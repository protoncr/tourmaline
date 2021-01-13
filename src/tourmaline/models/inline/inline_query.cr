module Tourmaline
  class InlineQuery
    include JSON::Serializable
    include Tourmaline::Model

    @[JSON::Field(ignore: true)]
    property! client : Tourmaline::Client

    getter id : String

    getter from : User

    getter location : Location?

    getter query : String

    getter offset : String

    def answer(results, **kwargs)
      client.answer_inline_query(id, results, **kwargs)
    end
  end
end
