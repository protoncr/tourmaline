![Header Image](img/header.png)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fwatzon%2Ftourmaline.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fwatzon%2Ftourmaline?ref=badge_shield)

[![Travis](https://img.shields.io/travis/watzon/tourmaline.svg)](https://travis-ci.org/watzon/tourmaline) ![Github search hit counter](https://img.shields.io/github/search/watzon/tourmaline/goto.svg) ![license](https://img.shields.io/github/license/watzon/tourmaline.svg)

Telegram Bot (and hopefully soon API) framework for Crystal. Based heavily off of [Telegraf](http://telegraf.js.org) this Crystal implementation allows your Telegram bot to be written in a language that's both beautiful and fast. Benchmarks coming soon.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tourmaline:
    github: watzon/tourmaline
```

## Usage

### Basic usage

```crystal
require "tourmaline"

alias TGBot = Tourmaline::Bot

bot = TGBot::Client.new(ENV["API_KEY"])

bot.command(["start", "help"]) do |message|
  text = "Echo bot is a sample bot created with the Tourmaline bot framework."
  bot.send_message(message.chat.id, text)
end

bot.command("echo") do |message, params|
  text = params.join(" ")
  bot.send_message(message.chat.id, text)
end

bot.poll
```

### Listening for events

Tourmaline has a number of events that you can listen for (the same events as Telegraf actually). The full list of events is as follows:

Standard update types:

- Message
- EditedMessage
- CallbackQuery
- InlineQuery
- ShippingQuery
- PreCheckoutQuery
- ChosenInlineResult
- ChannelPost
- EditedChannelPost

Update sub-types:

- Text
- Audio
- Document
- Photo
- Sticker
- Video
- Voice
- Contact
- Location
- Venue
- NewChatMembers
- LeftChatMember
- NewChatTitle
- NewChatPhoto
- DeleteChatPhoto
- GroupChatCreated
- MigrateToChatId
- SupergroupChatCreated
- ChannelChatCreated
- MigrateFromChatId
- PinnedMessage
- Game
- VideoNote
- Invoice
- SuccessfulPayment

All of which are available through the enum `Tourmaline::Bot::UpdateAction`

```crystal
bot.on(TGBot::UpdateAction::Text) do |update|
  text = update.message.not_nil!.text.not_nil!
  puts "TEXT: #{text}"
end
```

### Adding middleware

Middleware can be created by extending the `Tourmaline::Bot::Middleware` class. All middleware classes need to have a `call(update : Update)` method. The middleware will be called on every update.

```crystal

class MyMiddleware < TGBot::Middleware

  # All middlware include a reference to the parent bot.
  # @bot : Tourmaline::Bot::Client

  def call(update : Update)
    if message = update.message
      if user = message.from_user
        if text = message.text
          puts "#{user.first_name}: #{text}"
        end
      end
    end
  end

end

bot.use MyMiddleware
```

### Webhooks

Using webhooks is easy, even locally if you use the [ngrok.cr](https://github.com/watzon/ngrok.cr) package.

```crystal

# bot.poll

bot.set_webhook("https://example.com/bots/my_tg_bot")
bot.serve("0.0.0.0", 3400)

# or with ngrok.cr

require "ngrok"

Ngrok.start({ addr: "127.0.0.1:3400" }) do |ngrok|
  bot.set_webhook(ngrok.ngrok_url_https)
  bot.serve("127.0.0.1", 3400)
end
```

### Payments

You can now accept payments with your Tourmaline app! First make sure you follow the setup instructions [here](https://core.telegram.org/bots/payments) so that your bot is prepared to handle payments. Then just use the `send_invoice`, `answer_shipping_query`, and `answer_pre_checkout_query` methods to send invoices and accept payments.

```crystal
bot.command("buy") do |message, params|
  bot.send_invoice(
    message.chat.id,
    "Sample Invoice",
    "This is a test...",
    "123344232323",
    "YOUR_PROVIDER_TOKEN",
    "test1",
    "USD",
    bot.labeled_prices([{label: "Sample", amount: 299}, {label: "Another", amount: 369}]).to_json
  )
end
```

## Development

This currently supports the following features

- [x] Implementation examples
- [x] Easy command syntax
- [x] Robust middleware system
- [x] Standard API queries
- [x] Stickers
- [x] Inline mode
- [x] Long polling
- [x] Webhooks
- [x] Payments (*beta*)
- [ ] Games

If you want a new feature feel free to submit an issue or open a pull request.

## Contributing

1. Fork it ( https://github.com/watzon/tourmaline/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fwatzon%2Ftourmaline.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fwatzon%2Ftourmaline?ref=badge_large)