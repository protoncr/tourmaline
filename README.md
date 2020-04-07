![Header Image](img/header.png)

[![Chat on Telegram](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/protoncr)

Telegram Bot API framework written in Crystal. Based heavily off of [Telegraf](http://telegraf.js.org) this Crystal implementation allows your Telegram bot to be written in a language that's both beautiful and fast. Benchmarks coming soon.

If you want to extend your bot by using NLP, see my other library [Cadmium](https://github.com/cadmiumcr).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tourmaline:
    github: watzon/tourmaline
    version: ~> 0.15.0
```

## Usage

For usage information please see [the wiki](https://github.com/watzon/tourmaline/wiki). API documentation is also available [here](https://watzon.github.io/tourmaline/).

Examples are available in the [examples](./examples) folder.

## Development

This currently supports the following features:

- [x] Client API
  - [x] Implementation examples
  - [x] Easy command syntax
  - [x] Robust middleware system
  - [x] Standard API queries
  - [x] Stickers
  - [x] Inline mode
  - [x] Long polling
  - [x] Webhooks
  - [x] Payments
  - [x] Games
  - [x] Polls
  - [ ] Telegram Passport

If you want a new feature feel free to submit an issue or open a pull request.

## Who's Using Tourmaline

If you're using Tourmaline and would like to have your bot added to this list, just submit a PR!

- [fckeverywordbot](https://github.com/watzon/fckeverywordbot)

## Contributing

1. Fork it ( https://github.com/watzon/tourmaline/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
