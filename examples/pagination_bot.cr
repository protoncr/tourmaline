require "../src/tourmaline"
require "../src/tourmaline/extra/paged_inline_keyboard"

class PaginationBot < Tourmaline::Client
  @[Command("start")]
  def start_command(client, update)
    if message = update.message
      results = ('a'..'z').to_a.map(&.to_s)

      keyboard = PagedInlineKeyboard.new(
        results,
        per_page: 5,
        prefix: "{index}. ",
        footer: "\nPage: {page} of {page count}"
      )

      message.respond(keyboard.current_page, parse_mode: :markdown, reply_markup: keyboard)
    end
  end
end

bot = PaginationBot.new(ENV["API_KEY"])
bot.poll
