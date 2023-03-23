require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

roll_command = Tourmaline::CommandHandler.new("roll") do |ctx|
  ctx.reply_with_dice
end

throw_command = Tourmaline::CommandHandler.new("throw") do |ctx|
  ctx.reply_with_dart
end

shoot_command = Tourmaline::CommandHandler.new("shoot") do |ctx|
  ctx.reply_with_basketball
end

client.register(roll_command, throw_command, shoot_command)

client.poll
