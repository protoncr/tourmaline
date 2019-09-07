require "../src/tourmaline"

class EchoBot < Tourmaline::Bot
  include Tourmaline

  @[Command("echo")]
  def echo_command(message, params)
    text = params.join(" ")
    send_message(message.chat.id, text)
    delete_message(message.chat.id, message.message_id)
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll
