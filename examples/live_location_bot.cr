require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

send_live_location = Tourmaline::CommandHandler.new("start") do |ctx|
  begin
    lat = 40.7608
    lon = 111.8910
    loc = ctx.message.reply_with_location(lat, lon, live_period: 60)
    loop do
      lat += rand * 0.0001
      lon += rand * 0.0001
      loc.edit_live_location(lat, lon)
      sleep(5)
    end
  rescue ex : Tourmaline::Error::MessageCantBeEdited
  end
end

client.register(send_live_location)

client.poll
