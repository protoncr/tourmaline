require "../src/tourmaline"

class DiceBot < Tourmaline::Client
  @[Command("roll")]
  def roll_command(client, update)
    update.message.try &.reply_with_dice()
  end
end

bot = DiceBot.new(ENV["API_KEY"])
bot.poll
