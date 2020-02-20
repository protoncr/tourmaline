require "./handler"

module Tourmaline
  class HearsHandler < Handler
    ANNOTATIONS = [ Hears ]

    getter regexs : Array(Regex)
    getter proc : Proc(HearsContext, Void)

    def initialize(regexs : Regex | Array(Regex), proc : HearsContext ->)
      @regexs = regexs.is_a?(Array) ? regexs : [regexs]
      @proc = ->(ctx : HearsContext) { proc.call(ctx); nil }
    end

    def actions : Array(UpdateAction)
      [ UpdateAction::Message ]
    end

    def call(client : Client, update : Update)
      if (message = update.message) && (text = message.text)
        @regexs.each do |re|
          if match = re.match(text)
            context = HearsContext.new(client, update, message, text, match)
            @proc.call(context)
          end
        end
      end
    end

    def check_update(client : Client, update : Update) : Bool
      true
    end
  end

  # `HearsContext` represents the data passed into an `On` event. It wraps the `update`,
  # and possibly the `message`. It also includes access to the name of the event that
  # triggered it.
  #
  # Like the other events, missing methods are forwarded to the client in this one. Since
  # `message` might be nil, calls are not forwarded to it.
  record HearsContext, client : Tourmaline::Client, update : Tourmaline::Update,
    message : Tourmaline::Message, text : String, match : Regex::MatchData do
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
