module Tourmaline::Listeners
  @[ADI::Register]
  struct UpdateListener
    include AED::EventListenerInterface

    @[AEDA::AsEventListener(priority: 50)]
    def on_message(event : TLE::Update)
    end
  end
end
