require "../src/tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(client, update)
    if message = update.message
      text = update.context["text"].as_s
      message.reply(text)
    end
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll
