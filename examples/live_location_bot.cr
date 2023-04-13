require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

send_live_location = Tourmaline::CommandHandler.new("start") do |ctx|
  begin
    lat = 40.7608
    lon = 111.8910
    if loc = ctx.reply_with_location(latitude: lat, longitude: lon, live_period: 60)
      loop do
        lat += rand * 0.001
        lon += rand * 0.001
        ctx.edit_live_location(latitude: lat, longitude: lon)
        sleep(5)
      end
    end
  rescue ex : Tourmaline::Error::MessageCantBeEdited
    ctx.reply("Message can't be edited")
  end
end

client.register(send_live_location)

client.poll
