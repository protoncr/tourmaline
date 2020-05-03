require "kemal"
require "ngrok"

require "../src/tourmaline"
require "../src/tourmaline/adapters/kemal"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(client, update)
    if message = update.message
      text = update.context["text"].as_s
      message.reply(text)
    end
  end
end

Ngrok.start({addr: "127.0.0.1:3000"}) do |ngrok|
  # Add handler is a Kemal method for adding middleware
  add_handler Tourmaline::KemalAdapter.new(
    # pass in a new instance of your bot
    bot: EchoBot.new(ENV["API_KEY"]),
    # set the url
    url: ngrok.ngrok_url_https.not_nil!,
    # set the path to serve the webhook on
    path: "/bot-webhook/#{ENV["API_KEY"]}"
  )
end

Kemal.run
