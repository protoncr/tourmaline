module Tourmaline::Listeners
  @[ADI::Register]
  struct UpdateListener
    include AED::EventListenerInterface

    @[AEDA::AsEventListener(priority: 55)]
    def on_message(event : TLE::Update)
    end
  end
end
