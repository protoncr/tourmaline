require "../src/tourmaline"

class KittyBot < Tourmaline::Client
  REPLY_MARKUP = Markup.buttons([[
    "/kitty",
    "/kittygif",
  ]]).keyboard

  API_URL = "https://thecatapi.com/api/images/get"

  @[Command(["start", "help"])]
  def help_command(client, update)
    if message = update.message
      message.reply("😺 Use commands: /kitty, /kittygif and /about", reply_markup: REPLY_MARKUP)
    end
  end

  @[Command("about")]
  def about_command(client, update)
    if message = update.message
      text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
      message.reply(text)
    end
  end

  @[Command(["kitty", "kittygif"])]
  def kitty_command(client, update)
    if message = update.message
      # The time hack is to get around Telegram's image cache
      api = API_URL + "?time=#{Time.utc}&format=src&type="

      case update.context["command"].as_s
      when "kitty"
        message.chat.send_chat_action(:upload_photo)
        message.chat.send_photo(api + "jpg")
      when "kittygif"
        message.chat.send_chat_action(:upload_photo)
        message.chat.send_animation(api + "gif")
      else
      end
    end
  end
end

bot = KittyBot.new(ENV["API_KEY"])
bot.poll
