require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

start_command = Tourmaline::CommandHandler.new("start") do |ctx|
  keyboard = client.build_reply_keyboard_markup do |kb|
    kb.poll_request_button "Create poll", :regular
    kb.poll_request_button "Create quiz", :quiz
  end
  ctx.reply("Use the command /poll or /quiz to begin", reply_markup: keyboard)
end

poll_command = Tourmaline::CommandHandler.new("poll") do |ctx|
  ctx.reply_with_poll(
    "Your favorite math constant",
    ["x", "e", "π", "φ", "γ"],
    is_anonymous: false
  )
end

quiz_command = Tourmaline::CommandHandler.new("quiz") do |ctx|
  ctx.reply_with_poll(
    "2b|!2b",
    ["True", "False"],
    correct_option_id: 0,
    type: "quiz"
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
