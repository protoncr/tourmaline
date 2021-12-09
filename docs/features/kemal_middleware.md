# Kemal Middleware

If you're not aware, [kemal](https://kemalcr.com) is a lightweight web application framework for Crystal similar to Ruby's Sinatra. It is extremely fast, and prefect for hosting a Telegram bot, especially if you wish to also integrate a web front end, API, etc.

### The Kemal Adapter

Using Tourmaline in your Kemal project is pretty simple:

```crystal
require "kemal"
require "tourmaline/adapters/kemal"
require "./yourbot" # change this to your bot

# Add handler is a Kemal method for adding middleware
add_handler Tourmaline::KemalAdapter.new(
  # pass in a new instance of your bot
  bot: YourBot.new,
  # set the url
  url: "https://something.com",
  # set the path to serve the webhook on
  path: "/bot-webhook/#{ENV["TGBOT_API_KEY"]}"
)

Kemal.run
```
