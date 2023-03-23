require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

KEYBOARD = Tourmaline::ReplyKeyboardMarkup.build do
  poll_request_button "Create poll", :regular
  poll_request_button "Create quiz", :quiz
end

start_command = Tourmaline::CommandHandler.new("start") do |ctx|
  ctx.reply("Use the command /poll or /quiz to begin", reply_markup: KEYBOARD)
end

poll_command = Tourmaline::CommandHandler.new("poll") do |ctx|
  ctx.reply_with_poll(
    "Your favorite math constant",
    ["x", "e", "π", "φ", "γ"],
    anonymous: false
  )
end

quiz_command = Tourmaline::CommandHandler.new("quiz") do |ctx|
  ctx.reply_with_poll(
    "2b|!2b",
    ["True", "False"],
    correct_option_id: 0,
    type: Tourmaline::Poll::Type::Quiz
  )
end

client.register(start_command, poll_command, quiz_command)

client.on(:poll) do |ctx|
  puts "Poll update:"
  pp ctx.poll
end

client.on(:poll_answer) do |ctx|
  puts "Poll answer:"
  pp ctx.poll_answer
end

client.poll
