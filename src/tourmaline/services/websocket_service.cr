module Tourmaline
  @[ADI::Register]
  class WebsocketService
    def initialize(@dispatcher : AED::EventDispatcherInterface)
    end

    # Calls all handlers in the stack with the given update and
    # this client instance.
    def route(update : TLM::Update)
    end
  end
end
