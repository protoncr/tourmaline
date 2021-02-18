require "ngrok"
require "../src/tourmaline"

class Userbot < Tourmaline::Client
  @[Command("ping", prefix: ".")]
  def ping_command(ctx)
    ms = (self.ping * 1000).to_i
    ctx.message.reply("Pong!\nTook `#{ms}` ms", parse_mode: :markdown)
  end
end

bot = UserBot.new(
  endpoint: "https://tg.watzon.tech/"
)

token = bot.login "+18018362322"

print "Enter code: "
code = gets.to_s.strip

result = bot.send_code code
if result
  puts "Logged in! Your user_token is #{token}."
else
  puts "Failed to log in."
end

bot.poll
