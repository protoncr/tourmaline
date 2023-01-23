module Tourmaline
  abstract class CommandController < Controller
    macro inherited
      include AED::EventListenerInterface

      {% priority = 50 %}

      {% if ann = @type.annotation(TLA::Command) %}
        {% if commands = ann[:command] || ann[:commands] || ann[0] %}
          getter commands = {% if commands.is_a?(Array) %}\
            {{ commands.id }}
          {% else %}\
            [{{ commands.id.stringify }}]
          {% end %}\
        {% end %}

        {% if usage = ann[:usage] %}
          getter usage = {{ usage.id.stringify }}
        {% end %}

        {% if description = ann[:description] %}
          getter description = {{ description.id.stringify }}
        {% end %}

        {% if examples = ann[:example] || ann[:examples] %}
          getter examples = {% if examples.is_a?(Array) %}\
            {{ examples.id }}
          {% else %}\
            [{{ examples.id.stringify }}]
          {% end %}\
        {% end %}

        {% if ann[:priority] %}
          {% priority = ann[:priority] %}
        {% end %}
      {% else %}
        {% raise "Annotate your #{@type} with TLA::Command" %}
      {% end %}
    end
  end
end
