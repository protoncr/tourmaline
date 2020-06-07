module Tourmaline
  # Processes updates. `Update`s first get checked to see if they fit
  # into the given `UpdateAction` and then checked against the provided
  # Filter`s (if any).
  abstract class EventHandler

    getter group : String
    getter async : Bool

    def initialize(group = :default, async = true)
      @async = !!async
      @group = group.to_s
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
