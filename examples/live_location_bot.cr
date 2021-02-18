require "../src/tourmaline"

class LiveLocationBot < Tourmaline::Client
  @[Command("start")]
  def send_live_location(ctx)
    lat = 40.7608
    lon = 111.8910
    loc = ctx.message.reply_with_location(lat, lon, live_period: 60)
    loop do
      lat += rand * 0.0001
      lon += rand * 0.0001
      loc.edit_live_location(lat, lon)
      sleep(5)
    end
  rescue Error::MessageCantBeEdited
  end
end

bot = LiveLocationBot.new(bot_token: ENV["API_KEY"])
bot.poll
