require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

REPLY_MARKUP = Tourmaline::InlineKeyboardMarkup.build(columns: 2) do
  url_button "some super long button text which won't fit on most screens", "https://google.com"
  url_button "some other button", "https://google.com"
end

help_handler = Tourmaline::CommandHandler.new("start") do |ctx|
  ctx.reply("This is a button demo", reply_markup: REPLY_MARKUP)
end

client.register(help_handler)

client.poll
