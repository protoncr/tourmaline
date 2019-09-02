require "ngrok"
require "../src/tourmaline"

Ngrok.start({addr: "127.0.0.1:3400"}) do |ngrok|
  bot = Tourmaline::Bot.new(ENV["API_KEY"])

  bot.command("echo") do |message, params|
    text = params.join(" ")
    bot.send_message(message.chat.id, text)
    bot.delete_message(message.chat.id, message.message_id)
  end

  bot.set_webhook(ngrok.ngrok_url_https)
  bot.serve("127.0.0.1", 3400)
end
