require "../src/tourmaline"

class EchoBot < Tourmaline::Client
  HelloFilter = RegexFilter.new(/hello/) | RegexFilter.new(/hi/)

  @[On(:text, EchoBot::HelloFilter)]
  def on_hello(ctx)
    if message = ctx.message
      message.reply("https://nohello.com")
    end
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll
