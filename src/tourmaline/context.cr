module Tourmaline
  # # `CommandContext` represents the data passed into a bot command. It gives access to
  # # the `client`, the full `update`, the `message`, the `command`
  # # (including the prefix), and the raw message `text`
  # # (not including the command).
  # #
  # # Since it can be annoying and verbose to have to type `ctx.message.method`
  # # every time, `CommandContext` also forwards missing methods to the message,
  # # update, and client in that order. So rather than calling
  # # `ctx.message.reply` you can just do `ctx.reply`.
  # record CommandContext, client : Tourmaline::Client, update : Tourmaline::Update,
  #   message : Tourmaline::Message, command : String, text : String do
  #   macro method_missing(call)
  #     {% if Tourmaline::Message.has_method?(call.name) %}
  #       message.{{call}}
  #     {% elsif Tourmaline::Update.has_method?(call.name) %}
  #       update.{{call}}
  #     {% elsif Tourmaline::Client.has_method?(call.name) %}
  #       client.{{call}}
  #     {% else %}
  #       {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
  #     {% end %}
  #   end
  # end

  # # `EventContext` represents the data passed into an `On` event. It wraps the `update`,
  # # and possibly the `message`. It also includes access to the name of the event that
  # # triggered it.
  # #
  # # Like the other events, missing methods are forwarded to the client in this one. Since
  # # `message` might be nil, calls are not forwarded to it.
  # record EventContext, client : Tourmaline::Client, update : Tourmaline::Update,
  #   message : Tourmaline::Message?, event : Tourmaline::UpdateAction do
  #   macro method_missing(call)
  #     {% if Tourmaline::Update.has_method?(call.name) %}
  #       update.{{call}}
  #     {% elsif Tourmaline::Client.has_method?(call.name) %}
  #       client.{{call}}
  #     {% else %}
  #       {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
  #     {% end %}
  #   end
  # end

  # # `CallbackQueryContext` represents the data passed into an `Action` event. It includes
  # # access to the `client`, the full `update`, the `message`, the callback_query
  # # (`query`), and the query data.
  # #
  # # Missing methods are forwarded to, in order of most important, the `query`,
  # # `message`, `update`, and then `client`.
  # record CallbackQueryContext, client : Tourmaline::Client, update : Tourmaline::Update,
  #   message : Tourmaline::Message, query : Tourmaline::CallbackQuery, data : String do
  #   macro method_missing(call)
  #     {% if Tourmaline::CallbackQuery.has_method?(call.name) %}
  #       query.{{call}}
  #     {% elsif Tourmaline::Message.has_method?(call.name) %}
  #       message.{{call}}
  #     {% elsif Tourmaline::Update.has_method?(call.name) %}
  #       update.{{call}}
  #     {% elsif Tourmaline::Client.has_method?(call.name) %}
  #       client.{{call}}
  #     {% else %}
  #       {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
  #     {% end %}
  #   end
  # end
end
