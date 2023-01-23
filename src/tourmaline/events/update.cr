module Tourmaline
  module Events
    class Update < AED::Event
      getter update : TLM::Update

      getter actions : Array(TL::UpdateAction)

      def initialize(@update : TLM::Update)
        @actions = TL::UpdateAction.from_update(@update)
      end
    end
  end
end
