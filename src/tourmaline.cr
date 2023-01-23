require "db/pool"
require "athena-config"
require "athena-dependency_injection"
require "athena-event_dispatcher"
require "athena-serializer"

require "http_proxy"
require "mime/multipart"

require "./ext/*"
require "./tourmaline/config"
require "./tourmaline/annotations"
require "./tourmaline/event_dispatcher"
require "./tourmaline/helpers"
require "./tourmaline/exceptions"
require "./tourmaline/logger"
require "./tourmaline/parse_mode"
require "./tourmaline/chat_action"
require "./tourmaline/update_action"
require "./tourmaline/parsers/*"
require "./tourmaline/models/**"
require "./tourmaline/events/*"
require "./tourmaline/listeners/*"
require "./tourmaline/services/*"
require "./tourmaline/handler"
require "./tourmaline/controller"

alias TL = Tourmaline
alias TLA = Tourmaline::Annotations
alias TLM = Tourmaline::Model
alias TLE = Tourmaline::Events
alias TLDI = Athena::DependencyInjection

# Tourmaline is a Telegram Bot API library
# for [Telegram](https://telegram.com). It provides an easy to
# use interface for creating telegram bots, and using the
# various bot APIs that Telegram provides.
#
# For usage examples, see the
# [examples](https://github.com/watzon/tourmaline/tree/master/examples)
# directory. For guides on using Tourmaline, see the official
# Tourmaline [cookbook](https://tourmaline.dev/docs/cookbook/your-first-bot).
module Tourmaline
  module Models; end

  module Annotations; end

  module Exceptions; end

  module Listeners
    TAG = "tourmaline.event_dispatcher.listener"
  end

  module Events; end

  def self.configure(&block)
    yield Tourmaline::Config
  end

  def self.poll(*args, **kwargs)
    polling_service = ADI.container.tourmaline_polling_service
    polling_service.poll(*args, **kwargs)
  end
end
