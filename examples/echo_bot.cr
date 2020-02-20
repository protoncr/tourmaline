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

  @[On(:message)]
  def on_message(ctx)
    pp ctx.message
  end
end

bot = EchoBot.new(ENV["API_KEY"])
bot.poll

