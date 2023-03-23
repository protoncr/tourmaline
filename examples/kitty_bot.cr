require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

REPLY_MARKUP = Tourmaline::ReplyKeyboardMarkup.build do
  button "/kitty"
  button "/kittygif"
end

API_URL = "https://thecatapi.com/api/images/get"

help_command = Tourmaline::CommandHandler.new(["help", "start"]) do |ctx|
  ctx.reply("😺 Use commands: /kitty, /kittygif and /about", reply_markup: REPLY_MARKUP)
end

about_command = Tourmaline::CommandHandler.new("about") do |ctx|
  text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
  ctx.reply(text)
end

kitty_command = Tourmaline::CommandHandler.new(["kitty", "kittygif"]) do |ctx|
  # The time hack is to get around Telegram's image cache
  api = API_URL + "?time=#{Time.utc}&format=src&type="
  case ctx.command!
  when "kitty"
    ctx.send_chat_action(:upload_photo)
    ctx.respond_with_photo(api + "jpg")
  when "kittygif"
    ctx.send_chat_action(:upload_photo)
    ctx.respond_with_animation(api + "gif")
  else
  end
end

client.register(help_command, about_command, kitty_command)

client.poll

