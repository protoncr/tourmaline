require "../src/tourmaline"
require "../src/tourmaline/extra/paginated_keyboard"

class PaginationBot < Tourmaline::Client
  @[Command("start")]
  def start_command(ctx)
    results = ('a'..'z').to_a.map(&.to_s)

    keyboard = PaginatedKeyboard.new(
      self,
      results: results,
      per_page: 5,
      prefix: "{index}. ",
      footer: "\nPage: {page} of {page count}"
    )

    ctx.message.reply_with_paginated_keyboard(keyboard, parse_mode: :markdown)
  end
end

bot = PaginationBot.new(bot_token: ENV["API_KEY"])
bot.poll
