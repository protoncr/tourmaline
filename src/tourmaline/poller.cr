module Tourmaline
  # The `Poller` class is responsible for polling Telegram's API for updates,
  # and then passing them to the `Dispatcher` for processing.
  class Poller
    Log = ::Log.for(self)

    getter offset : Int64

    def initialize(client : Tourmaline::Client)
      @client = client
      @offset = 0_i64
      @polling = false
    end

    # Starts polling Telegram's API for updates.
    def start
      @client.delete_webhook
      Log.info { "Polling for updates..." }
      @polling = true
      while @polling
        updates = @client.get_updates(offset: offset, timeout: 30)
        updates.each do |update|
          @client.dispatcher.process(update)
          @offset = update.update_id + 1
        end
      end
    end

    def stop
      @polling = false
    end
  end
end
