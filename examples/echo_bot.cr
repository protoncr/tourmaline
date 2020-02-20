require "../src/tourmaline"

class EchoBot < Tourmaline::Client
  include Tourmaline

  def initialize(api_key)
    super(api_key)
  end

  @[Command("echo")]
  def echo_command(ctx)
    ctx.reply(ctx.text)
  end

  @[Hears(/hello/i)]
  def on_message(ctx)
    ctx.reply("Hi there")
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll

