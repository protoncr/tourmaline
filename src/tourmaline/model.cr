module Tourmaline
  module Model
    @[JSON::Field(ignore: true)]
    property! client : Tourmaline::Client

    def finish_init(client : Tourmaline::Client)
      {% begin %}
        @client = client
        {% for var in @type.instance_vars %}
          {% if var.type.resolve <= Tourmaline::Model? %}
            @{{var.id}}.try(&.finish_init(client))
          {% end %}
        {% end %}
      {% end %}
    end
  end
end

require "./models/*"
