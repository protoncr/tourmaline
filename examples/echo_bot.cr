require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

echo_handler = Tourmaline::CommandHandler.new("echo") do |ctx|
  text = ctx.text.to_s
  ctx.reply(text) unless text.empty?
end

client.register(echo_handler)

client.poll
