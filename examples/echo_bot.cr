require "../src/tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.message.reply(ctx.text)
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.serve
