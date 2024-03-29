<div align="center">
  <img src="./img/logo.png" alt="tourmaline logo">
</div>

# Tourmaline

[![Chat on Telegram](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/protoncr)

Telegram Bot API library written in Crystal. Meant to be a simple, easy to use, and fast library for writing Telegram bots.

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

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

echo_handler = Tourmaline::CommandHandler.new("echo") do |ctx|
  text = ctx.text.to_s
  ctx.reply(text) unless text.empty?
end

client.register(echo_handler)

client.poll
```

## Roadmap

The following features are/will be implemented:

- [x] HTTP/HTTP Proxies
- [x] Client API
  - [x] Implementation examples
  - [x] Handlers for commands, queries, and more
  - [x] Robust middleware system
  - [x] Standard API queries
  - [x] Stickers
  - [x] Inline mode
  - [x] Long polling
  - [x] Webhooks
  - [x] Payments
  - [x] Games
  - [x] Polls
  - [x] Telegram Passport
- [ ] Framework Adapters
  - [ ] Kemal
  - [ ] Amber
  - [ ] Lucky
  - [ ] Athena
  - [ ] Grip

If you want a new feature feel free to submit an issue or open a pull request.

## Contributing

1. Fork it ( https://github.com/protoncr/tourmaline/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

Thanks to all the people that have contributed to this project!

[![Contributors](https://contrib.rocks/image?repo=protoncr/tourmaline)](https://github.com/protoncr/tourmaline/graphs/contributors)
