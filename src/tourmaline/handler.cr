module Tourmaline
  abstract class HandlerBase
    macro inherited
      macro finished
        \{%
           unless @type.has_constant?("ANNOTATION")
             raise "Event handlers must have an ANNOTATION constant which references a valid annotation."
           end
        %}
      end
    end

    def filter(_update : TLM::Update) : Bool
      true
    end

    abstract def call(update : TLM::Update)

    # :nodoc:
    def register_annotations
      {% begin %}
        {% for handler in HandlerBase.subclasses %}
          {% for method in Tourmaline::Controller.methods %}
            {% handler_annotation = handler.constant("ANNOTATION").resolve %}
            {% if method.annotation(handler_annotation) %}
              %handler = {{handler}}.new
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end
  end
end

require "./handlers/*"
