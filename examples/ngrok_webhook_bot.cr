require "../src/tourmaline"
require "ngrok"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.reply(ctx.text)
  end
end

Ngrok.start({addr: "127.0.0.1:3400"}) do |ngrok|
  bot = EchoBot.new(ENV["API_KEY"])
  bot.set_webhook(ngrok.ngrok_url_https)
  bot.serve("127.0.0.1", 3400)
end
