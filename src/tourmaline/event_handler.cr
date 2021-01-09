module Tourmaline
  # Base class for all handlers.
  abstract class EventHandler

    getter group : String

    getter priority : Int32

    def initialize(group = :default, priority = 0)
      @group = group.to_s
      @priority = priority.to_i
    end

    abstract def call(client : Client, update : Update)

    # :nodoc:
    module Annotator
      private def register_event_handler_annotations
        {% begin %}
          {% for subclass in Tourmaline::EventHandler.subclasses %}
            {{ subclass.id }}.annotate(self)
          {% end %}
        {% end %}
      end
    end
  end
end

require "./handlers/*"
