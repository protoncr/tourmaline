require "../src/tourmaline"

class KittyBot < Tourmaline::Bot
  include Tourmaline

  REPLY_MARKUP = Markup.keyboard([
    ["/kitty"], ["/kittygif"],
  ])

  API_URL = "https://thecatapi.com/api/images/get"

  @[Command(["start", "help"])]
  def help_command(message, params)
    message.chat.send_message("😺 Use commands: /kitty, /kittygif and /about", reply_markup: REPLY_MARKUP)
  end

  @[Command("about")]
  def about_command(message, params)
    text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
    message.chat.send_message(text)
  end

  @[Command(["kitty", "kittygif"])]
  def kitty_command(message, params)
    # The time hack is to get around Telegram's image cache
    api = API_URL + "?time=#{Time.now}&format=src&type="
    cmd = message.text.to_s.split(" ")[0]

    if cmd == "/kitty"
      message.chat.send_chat_action(:upload_photo)
      message.chat.send_photo(api + "jpg")
    else
      message.chat.send_chat_action(:upload_photo)
      message.chat.send_animation(api + "gif")
    end
  end
end

bot = KittyBot.new(ENV["API_KEY"])
bot.poll
