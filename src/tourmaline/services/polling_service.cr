require "./telegram_service"

module Tourmaline
  @[ADI::Register(public: true)]
  class PollingService
    def initialize(@tg : Tourmaline::TelegramService, @router : Tourmaline::RoutingService)
    end

    # Start polling for updates. This method uses a combination of `#get_updates`
    # and `#handle_update` to send continuously check Telegram's servers
    # for updates.
    def poll(delete_webhook = false)
      @tg.poll(delete_webhook) do |update|
        spawn @router.route(update)
      end
    end
  end
end
