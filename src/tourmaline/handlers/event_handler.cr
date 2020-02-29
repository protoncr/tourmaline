module Tourmaline
  class EventHandler < Handler
    ANNOTATIONS = [ On ]

    getter event : UpdateAction
    getter proc : Proc(EventContext, Void)

    def initialize(event : Tourmaline::UpdateAction, &proc : EventContext ->)
      @event = event
      @proc = ->(ctx : EventContext) { proc.call(ctx); nil }
    end

    def actions : Array(UpdateAction)
      {{ Tourmaline::UpdateAction.constants.map { |c| ("Tourmaline::UpdateAction::" + c.stringify).id } }}
    end

    def call(client : Client, update : Update)
      actions = Helpers.actions_from_update(update)
      actions.each do |action|
        if @event == action
          context = EventContext.new(client, update, update.message, actions)
          @proc.call(context)
        end
      end
    end

    def check_update(client : Client, update : Update) : Bool
      true
    end
  end

  # `EventContext` represents the data passed into an `On` event. It wraps the `update`,
  # and possibly the `message`. It also includes access to the name of the event that
  # triggered it.
  #
  # Like the other events, missing methods are forwarded to the client in this one. Since
  # `message` might be nil, calls are not forwarded to it.
  record EventContext, client : Tourmaline::Client, update : Tourmaline::Update,
    message : Tourmaline::Message?, events : Array(Tourmaline::UpdateAction) do
    macro method_missing(call)
      {% if Tourmaline::Update.has_method?(call.name) %}
        update.{{call}}
      {% elsif Tourmaline::Client.has_method?(call.name) %}
        client.{{call}}
      {% else %}
        {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
      {% end %}
    end
  end
end
