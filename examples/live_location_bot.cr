require "../src/tourmaline"

class LiveLocationBot < Tourmaline::Client
  @[Command("start")]
  def send_live_location(client, update)
    lat = 40.7608
    lon = 111.8910
    message = update.message.try &.reply_with_location(lat, lon, live_period: 60)
    60.times do
      lat += rand * 0.001
      lon += rand * 0.001
      message.edit_live_location(lat, lon)
      sleep(1)
    end
  end
end

bot = LiveLocationBot.new(ENV["API_KEY"])
bot.poll
