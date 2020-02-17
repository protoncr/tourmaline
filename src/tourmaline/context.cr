module Tourmaline
  # `Context` represents the data passed into a bot command. It gives access to
  # the `client`, the full `update`, the `message`, the `command`
  # (including the prefix), and the raw message `text`
  # (not including the command).
  #
  # Since it can be annoying and verbose to have to type `ctx.message.method`
  # every time, `Context` also forwards missing methods to the message,
  # update, and client in that order. So rather than calling
  # `ctx.message.reply` you can just do `ctx.reply`.
  record Context, client : Tourmaline::Bot, update : Tourmaline::Update,
      message : Tourmaline::Message, command : String, text : String do
    macro method_missing(call)
      {% if Tourmaline::Message.has_method?(call.name) %}
        message.{{call}}
      {% elsif Tourmaline::Update.has_method?(call.name) %}
        update.{{call}}
      {% elsif Tourmaline::Bot.has_method?(call.name) %}
        client.{{call}}
      {% else %}
        {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
      {% end %}
    end
  end
end
