<div align="center">
  <img src="./img/logo.png" alt="tourmaline logo">
</div>

# Tourmaline

[![Chat on Telegram](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/protoncr)

Telegram Bot API framework written in Crystal. Based heavily off of [Telegraf](http://telegraf.js.org) this Crystal implementation allows your Telegram bot to be written in a language that's both beautiful and fast. Benchmarks coming soon.

If you want to extend your bot by using NLP, see my other library [Cadmium](https://github.com/cadmiumcr).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tourmaline:
    github: protoncr/tourmaline
    branch: master
```

## Usage

API documentation is also available [here](https://tourmaline.dev/api_reference/Tourmaline/).

Examples are available in the [examples](https://github.com/protoncr/tourmaline/tree/master/examples) folder.

Just for README purposes though, let's look at the echo bot example:

```crystal
require "tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.message.reply(ctx.text)
  end
end

bot = EchoBot.new(bot_token: ENV["API_KEY"])
bot.poll
```

## Development

This currently supports the following features:

- [x] Client API
  - [x] Implementation examples
  - [x] Easy command syntax
  - [ ] Robust middleware system
  - [x] Standard API queries
  - [x] Stickers
  - [x] Inline mode
  - [x] Long polling
  - [x] Webhooks
  - [x] Payments
  - [x] Games
  - [x] Polls
  - [x] Telegram Passport
- [x] HTTP/HTTP Proxies

If you want a new feature feel free to submit an issue or open a pull request.

## Who's Using Tourmaline

If you're using Tourmaline and would like to have your bot added to this list, just submit a PR!

- [PixieImageBot](https://t.me/pixieimagebot)
- [Utilibot](https://t.me/watzonutilitbot)

## Contributing

1. Fork it ( https://github.com/protoncr/tourmaline/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
