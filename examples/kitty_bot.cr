require "../src/tourmaline"

bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])

reply_markup = Tourmaline::Bot::ReplyKeyboardMarkup.new([
  ["/kitty"], ["/kittygif"],
])

bot.command(["start", "help"]) do |message|
  bot.send_message(
    message.chat.id,
    "😺 Use commands: /kitty, /kittygif and /about",
    reply_markup: reply_markup)
end

bot.command("about") do |message|
  text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
  bot.send_message(message.chat.id, text)
end

bot.command(["kitty", "kittygif"]) do |message|
  # The time hack is to get around Telegrsm's image cache
  api = "https://thecatapi.com/api/images/get?time=%{time}&format=src&type=" % {time: Time.now}
  cmd = message.text.not_nil!.split(" ")[0]

  if cmd == "/kitty"
    bot.send_chat_action(message.chat.id, Tourmaline::Bot::ChatAction::UploadPhoto)
    bot.send_photo(message.chat.id, api + "jpg")
  else
    bot.send_chat_action(message.chat.id, Tourmaline::Bot::ChatAction::UploadDocument)
    bot.send_document(message.chat.id, api + "gif")
  end
end

bot.poll
