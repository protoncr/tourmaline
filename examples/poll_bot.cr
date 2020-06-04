require "../src/tourmaline"

class PollBot < Tourmaline::Client
  KEYBOARD = ReplyKeyboardMarkup.build do
    poll_request_button "Create poll", :regular
    poll_request_button "Create quiz", :quiz
  end

  @[Command("start")]
  def start_command(client, update)
    if message = update.message
      message.reply("Use the command /poll or /quiz to begin", reply_markup: KEYBOARD)
    end
  end

  @[On(:poll)]
  def on_poll(client, update)
    puts "Poll update:"
    pp update.poll
  end

  @[On(:poll_answer)]
  def on_poll_answer(client, update)
    puts "Poll answer:"
    pp update.poll_answer
  end

  @[Command("poll")]
  def poll_command(client, update)
    update.message.try &.reply_with_poll(
      "Your favorite math constant",
      ["x", "e", "π", "φ", "γ"],
      anonymous: false
    )
  end

  @[Command("quiz")]
  def quiz_command(client, update)
    update.message.try &.reply_with_poll(
      "2b|!2b",
      ["True", "False"],
      correct_option_id: 0,
      type: PollType::Quiz
    )
  end
end

bot = PollBot.new(ENV["API_KEY"])
bot.poll
