require "ngrok"
require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

echo_handler = Tourmaline::CommandHandler.new("echo") do |ctx|
  text = ctx.text.to_s
  ctx.reply(text) unless text.empty?
end

client.register(echo_handler)

Ngrok.start(addr: "127.0.0.1:3000") do |ngrok|
  path = "/bot-webhook/#{ENV["BOT_TOKEN"]}"
  client.set_webhook(File.join(ngrok.url_https.to_s, path))
  client.serve(host: "127.0.0.1", port: 3000, path: path)
end
