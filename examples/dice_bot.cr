require "../src/tourmaline"

class DiceBot < Tourmaline::Client
  @[Command("roll")]
  def roll_command(ctx)
    ctx.message.reply_with_dice
  end

  @[Command("throw")]
  def throw_command(ctx)
    ctx.message.reply_with_dart
  end

  @[Command("shoot")]
  def shoot_command(ctx)
    ctx.message.reply_with_basketball
  end
end

bot = DiceBot.new(ENV["API_KEY"])
bot.poll
