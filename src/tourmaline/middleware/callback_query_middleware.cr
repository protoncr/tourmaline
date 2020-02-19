module Tourmaline
  class CallbackQueryMiddleware
    include MiddlewareInterface

    getter callback_handlers = {} of String => Array(Proc(CallbackQueryMiddleware::Context, Nil))

    def init(bot : Tourmaline::Bot)
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(OnCallbackQuery) || method.annotation(Tourmaline::OnCallbackQuery)) %}
              %proc = ->(ctx : CallbackQueryMiddleware::Context) { {{method.name.id}}(ctx); nil }
              action({{ann[0]}}, %proc)
            {% end %}
          {% end %}
        {% end %}
        @callback_handlers
      {% end %}
    end

    def call(ctx : Middleware::Context)
      ctx.bot.logger.debug(ctx.update.to_pretty_json)
    end

    @[Export]
    def action(action : String | Symbol | Array(String | Symbol), proc : Tourmaline::ActionContext ->)
      if action.is_a?(Array)
        action.each { |a| action(a) }
      else
        @action_handlers[action.to_s] ||= [] of Proc(Tourmaline::ActionContext, Nil)
        @action_handlers[action.to_s] << proc
      end
    end

    @[Export]
    def action(action : String | Symbol | Array(String | Symbol), &block : Tourmaline::ActionContext ->)
      action(action, block)
    end

    # `Context` represents the data passed into an `Action` event. It includes
    # access to the `client`, the full `update`, the `message`, the callback_query
    # (`query`), and the query data.
    #
    # Missing methods are forwarded to, in order of most important, the `query`,
    # `message`, `update`, and then `client`.
    record Context, client : Tourmaline::Bot, update : Tourmaline::Update,
      message : Tourmaline::Message, query : Tourmaline::CallbackQuery, data : String do
      macro method_missing(call)
        {% if Tourmaline::CallbackQuery.has_method?(call.name) %}
          query.{{call}}
        {% elsif Tourmaline::Message.has_method?(call.name) %}
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
end
