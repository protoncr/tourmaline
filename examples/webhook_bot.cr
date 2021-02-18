require "ngrok"
require "../src/tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.message.reply(ctx.text)
  end
end

Ngrok.start(addr: "127.0.0.1:3000") do |ngrok|
  bot = EchoBot.new(bot_token: ENV["API_KEY"])
  path = "/bot-webhook/#{ENV["API_KEY"]}"

  bot.set_webhook(File.join(ngrok.url_https.to_s, path))
  bot.serve(host: "127.0.0.1", port: 3000, path: path)
end
