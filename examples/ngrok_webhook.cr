require "../src/tourmaline"
require "ngrok"

class EchoBot < Tourmaline::Bot
  include Tourmaline

  @[Command("echo")]
  def echo_command(message, params)
    text = params.join(" ")
    send_message(message.chat.id, text)
    delete_message(message.chat.id, message.message_id)
  end
end

Ngrok.start({addr: "127.0.0.1:3400"}) do |ngrok|
  bot = EchoBot.new(ENV["API_KEY"])
  bot.set_webhook(ngrok.ngrok_url_https)
  bot.serve("127.0.0.1", 3400)
end
