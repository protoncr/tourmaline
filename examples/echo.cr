require "../src/tourmaline"

bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])

bot.command("echo") do |message, params|
  text = params.join(" ")
  bot.send_message(message.chat.id, text)
  bot.delete_message(message.chat.id, message.message_id+1)
end

bot.poll
