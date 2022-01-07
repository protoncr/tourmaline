require "../src/tourmaline"

class ButtonBot < Tourmaline::Client
  REPLY_MARKUP = InlineKeyboardMarkup.build(columns: 2) do
    url_button "some super long button text which won't fit on most screens", "https://google.com"
    url_button "some other button", "https://google.com"
  end

  @[Command("start")]
  def help_command(ctx)
    ctx.message.reply("This is a button demo", reply_markup: REPLY_MARKUP)
  end
end

bot = ButtonBot.new(bot_token: ENV["API_KEY"])
bot.poll
