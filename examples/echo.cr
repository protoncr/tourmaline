require "../src/tourmaline"

class EchoBot < Tourmaline::Bot
  include Tourmaline

  @[Command("echo")]
  def echo_command(message, params)
    text = params.join(" ")
    message.chat.send_message(text)
    message.delete
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll
