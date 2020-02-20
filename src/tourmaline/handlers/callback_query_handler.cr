module Tourmaline
  class CallbackQueryHandler < Handler
    ANNOTATIONS = [ OnCallbackQuery ]

    getter data : String?
    getter proc : Proc(CallbackQueryContext, Void)

    def initialize(proc : CallbackQueryContext ->, data = nil)
      @data = data
      @proc = ->(ctx : CallbackQueryContext) { proc.call(ctx); nil }
    end

    def actions : Array(UpdateAction)
      [ UpdateAction::CallbackQuery ]
    end

    def call(client : Client, update : Update)
      if (query = update.callback_query) &&
          (message = query.message)
        if !@data || @data == query.data
          context = CallbackQueryContext.new(client, update, message, query, query.data)
          @proc.call(context)
        end
      end
    end

    def check_update(client : Client, update : Update) : Bool
      true
    end
  end

  # `CallbackQueryContext` represents the data passed into an `On` event. It wraps the `update`,
  # and possibly the `message`. It also includes access to the name of the event that
  # triggered it.
  #
  # Like the other events, missing methods are forwarded to the client in this one. Since
  # `message` might be nil, calls are not forwarded to it.
  record CallbackQueryContext, client : Tourmaline::Client, update : Tourmaline::Update,
    message : Tourmaline::Message, query : Tourmaline::CallbackQuery, data : String? do
    macro method_missing(call)
      {% if Tourmaline::Message.has_method?(call.name) %}
        message.{{call}}
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
