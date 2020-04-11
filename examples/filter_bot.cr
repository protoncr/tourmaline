require "../src/tourmaline"

class FilterBot < Tourmaline::Client
  HelloFilter = RegexFilter.new(/hello/) | RegexFilter.new(/hi/)

  @[On(:text, FilterBot::HelloFilter)]
  def on_hello(client, update)
    if message = update.message
      message.reply("https://nohello.com")
    end
  end
end

bot = FilterBot.new(ENV["API_KEY"])
bot.poll
