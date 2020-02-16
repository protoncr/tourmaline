require "../src/tourmaline"

class PollBot < Tourmaline::Bot
  include Tourmaline

  KEYBOARD = Markup.buttons([[
    Markup.poll_request_button("Create poll", "regular"),
    Markup.poll_request_button("Create quiz", "quiz")
  ]]).keyboard

  @[On(:poll)]
  def on_poll(update)
    puts "Poll update:"
    pp update.poll
  end

  @[On(:poll_answer)]
  def on_poll_answer(update)
    puts "Poll answer:"
    pp update.poll_answer
  end

  @[Command("poll")]
  def poll_command(ctx)
    ctx.message.reply_with_poll(
      "Your favorite math constant",
      ["x", "e", "π", "φ", "γ"],
      anonymous: false
    )
  end

  @[Command("quiz")]
  def quiz_command(ctx)
    ctx.message.reply_with_poll(
      "2b|!2b",
      ["True", "False"],
      correct_option_id: 0,
      type: PollType::Quiz
    )
  end
end

bot = PollBot.new(ENV["API_KEY"])
bot.poll
