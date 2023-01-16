module Tourmaline
  module Events
    class Command < AED::Event
      getter trigger : String

      getter text : String

      getter message : Tourmaline::Model::Message

      def initialize(@trigger : String, @text : String, @message : Tourmaline::Model::Message)
      end
    end
  end
end
