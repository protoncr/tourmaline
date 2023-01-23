module Tourmaline
  @[ADI::Register]
  class HandlerRegistryService
    HANDLERS = [] of HandlerBase

    def initialize
      @handlers = [] of HandlerBase
    end

    def register(handler : HandlerBase)
      @handlers << handler
    end

    def unregister(handler : HandlerBase)
      @handlers.delete handler
    end
  end
end
