module Tourmaline
  @[ADI::Register]
  class RoutingService
    def initialize(@dispatcher : AED::EventDispatcherInterface)
    end

    # Calls all handlers in the stack with the given update and
    # this client instance.
    def route(update : TLM::Update)
      @dispatcher.dispatch(TLE::Update.new(update))
    end
  end
end
