require "http_proxy"
require "mime/multipart"

require "./ext/*"
require "./tourmaline/version"
require "./tourmaline/client"

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
  include Tourmaline::Handlers
  include Tourmaline::Annotations
end
