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

    ctx.message.respond(keyboard.current_page, parse_mode: :markdown, reply_markup: keyboard)
  end
end

bot = PaginationBot.new(ENV["API_KEY"])
bot.poll
