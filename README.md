# Tourmaline

Telegram Bot (and hopefully soon API) framework for Crystal. Based heavily off of [Telegraf](http://telegraf.js.org) this Crystal implementation allows your Telegram bot to be written in a language that's both beautiful and fast. Benchmarks coming soon.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tourmaline:
    github: watzon/tourmaline
```

## Usage

More usage examples will be coming soon, until then here's a sample echo bot implementation.

```crystal
require "tourmaline"

bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])

bot.command("echo") do |message, params|
  text = params.join(" ")
  bot.send_message(message.chat.id, text)
end

bot.poll
```

## Development

This currently supports the following features

- [x] Easy Command Syntax
- [x] Standard API queries
- [x] Stickers
- [x] Inline Mode
- [ ] Payments
- [ ] Games
- [x] Long Polling
- [x] Webhooks (_need testing_)
- [ ] Ngrok integration for easier webhook testing

If you want a new feature feel free to submit an issue or open a pull request.

## Contributing

1. Fork it ( https://github.com/watzon/tourmaline/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
