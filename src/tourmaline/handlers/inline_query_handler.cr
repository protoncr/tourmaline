module Tourmaline
  class InlineQueryHandler < Handler
    ANNOTATIONS = [ OnInlineQuery ]

    getter id : String?
    getter query : String?
    getter proc : Proc(InlineQueryContext, Void)

    def initialize(
      id : String? = nil,
      query : String? = nil,
      &proc : InlineQueryContext ->
    )
      @id = id
      @query = query
      @proc = ->(ctx : InlineQueryContext) { proc.call(ctx); nil }
    end

    def actions : Array(UpdateAction)
      [ UpdateAction::InlineQuery ]
    end

    def call(client : Client, update : Update)
      if (query = update.inline_query)
        context = InlineQueryContext.new(client, update, query, query.id, query.query)
        @proc.call(context)
      end
    end

    def check_update(client : Client, update : Update) : Bool
      if (query = update.inline_query)
        if (!@id && !@query)
          return true
        end

        if (@id && @id == query.id) ||
            (@query && @query == query.query)
          return true
        end
      end
      false
    end
  end

  # `InlineQueryContext` represents the data passed into an `On` event. It wraps the `update`,
  # and possibly the `message`. It also includes access to the name of the event that
  # triggered it.
  #
  # Like the other events, missing methods are forwarded to the client in this one. Since
  # `message` might be nil, calls are not forwarded to it.
  record InlineQueryContext, client : Tourmaline::Client, update : Tourmaline::Update,
    inline_query : InlineQuery, id : String, query : String? do
    macro method_missing(call)
      {% if Tourmaline::InlineQuery.has_method?(call.name) %}
        inline_query.{{call}}
      {% elsif Tourmaline::Update.has_method?(call.name) %}
        update.{{call}}
      {% elsif Tourmaline::Client.has_method?(call.name) %}
        client.{{call}}
      {% else %}
        {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
      {% end %}
    end
  end
end
