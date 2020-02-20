module Tourmaline
  abstract class Handler


    abstract def actions : Array(UpdateAction)

    abstract def call(client : Client, update : Update)

    abstract def check_update(client : Client, update : Update) : Bool

    def handle_update(client : Client, update : Update)
      if check_update(client, update)
        call(client, update)
      end
    end

    module Annotator
      private def register_annotated_methods
        {% begin %}
          {% for command_class in Tourmaline::Client.subclasses %}
            {% for handler in Tourmaline::Handler.subclasses %}
              {% for method in command_class.methods %}
                {% used_annotations = [] of Annotation %}
                {% if handler.has_constant?(:ANNOTATIONS) %}
                  {% for _annotation in handler.constant("ANNOTATIONS") %}
                    {% _annotation = _annotation.resolve %}
                    {% if used_annotations.includes?(_annotation) %}
                      {% raise "Annotation '#{_annotation.stringify}' was already registered." %}
                    {% else %}
                      {% used_annotations << _annotation %}
                    {% end %}

                    {% if ann = method.annotation(_annotation) %}
                      {% init = handler.methods.find { |d| d.name.stringify == "initialize" } %}
                      {% args = init.args %}
                      add_handler({{ handler.resolve }}.new(
                        {% for arg, i in init.args %}
                          {% if arg.name == "proc" %}
                            {% inputs = arg.restriction.inputs %}\
                            {{ arg.name }}: {{ ("->(" + inputs.map_with_index { |a, i| "v#{i} : #{a}" }.join(", ") +  ") { #{method.name.id}(" + inputs.map_with_index { |_, i| "v#{i}" }.join(", ") + "); nil }").id }},
                          {% else %}
                            {{ arg.name }}: {{ ann[arg.name] || ann[i] || arg.default_value }}{% unless i == init.args.size - 1 %},{% end %}
                          {% end %}
                        {% end %}
                      ))
                    {% end %}
                  {% end %}
                {% end %}
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end

require "./handlers/*"
