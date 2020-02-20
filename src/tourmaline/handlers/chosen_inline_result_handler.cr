module Tourmaline
  class ChosenInlineResultHandler < Handler
    ANNOTATIONS = [ OnChosenInlineResult ]

    getter id : String?
    getter query : String?
    getter inline_message_id : String?
    getter proc : Proc(ChosenInlineResultContext, Void)

    def initialize(
      proc : ChosenInlineResultContext ->,
      id : String? = nil,
      query : String? = nil,
      inline_message_id : String? = nil
    )
      @id = id
      @query = query
      @inline_message_id = inline_message_id
      @proc = ->(ctx : ChosenInlineResultContext) { proc.call(ctx); nil }
    end

    def actions : Array(UpdateAction)
      [ UpdateAction::ChosenInlineResult ]
    end

    def call(client : Client, update : Update)
      if (result = update.chosen_inline_result)
        context = ChosenInlineResultContext.new(client, update, result, result.result_id, result.query, result.inline_message_id)
        @proc.call(context)
      end
    end

    def check_update(client : Client, update : Update) : Bool
      if (result = update.chosen_inline_result)
        if (!@id && !@query && !@inline_message_id)
          puts "true 1"
          return true
        end

        if (@id && @id == result.result_id) ||
            (@query && @query == result.query) ||
              (@inline_message_id && @inline_message_id == result.inline_message_id)
          return true
        end
      end
      false
    end
  end

  # `ChosenInlineResultContext` represents the data passed into an `On` event. It wraps the `update`,
  # and possibly the `message`. It also includes access to the name of the event that
  # triggered it.
  #
  # Like the other events, missing methods are forwarded to the client in this one. Since
  # `message` might be nil, calls are not forwarded to it.
  record ChosenInlineResultContext, client : Tourmaline::Client, update : Tourmaline::Update,
    result : ChosenInlineResult, id : String, query : String?, inline_message_id : String? do
    macro method_missing(call)
      {% if Tourmaline::ChosenInlineResult.has_method?(call.name) %}
        result.{{call}}
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
