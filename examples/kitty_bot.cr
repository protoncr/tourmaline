require "../src/tourmaline"

class KittyBot < Tourmaline::Bot
  include Tourmaline

  REPLY_MARKUP = Tourmaline::Model::ReplyKeyboardMarkup.new([
    ["/kitty"], ["/kittygif"],
  ])

  API_URL = "https://thecatapi.com/api/images/get"

  @[Command(["start", "help"])]
  def help_command(message, params)
    send_message(
      message.chat.id,
      "😺 Use commands: /kitty, /kittygif and /about",
      reply_markup: REPLY_MARKUP)
  end

  @[Command("abount")]
  def about_command(message, params)
    text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
    send_message(message.chat.id, text)
  end

  @[Command(["kitty", "kittygif"])]
  def kitty_command(message, params)
    # The time hack is to get around Telegram's image cache
    api = API_URL + "?time=#{Time.now}&format=src&type="
    cmd = message.text.not_nil!.split(" ")[0]

    if cmd == "/kitty"
      send_chat_action(message.chat.id, :upload_photo)
      send_photo(message.chat.id, api + "jpg")
    else
      send_chat_action(message.chat.id, :upload_document)
      send_document(message.chat.id, api + "gif")
    end
  end
end

bot = KittyBot.new(ENV["API_KEY"])
bot.poll
