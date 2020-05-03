require "../src/tourmaline"

class PaginationBot < Tourmaline::Client
  DATA = (1..100).to_a.map(&.to_s)
  PER_PAGE = 10

  @[Command("start")]
  def start_command(client, update)
    if message = update.message
      content = get_page(0)
      keyboard = get_keyboard(0)
      message.respond(content, reply_markup: keyboard)
    end
  end

  def get_page(num)
    DATA[num * PER_PAGE, PER_PAGE].join("\n")
  end

  def get_keyboard(page)
    pages_count = DATA.size // PER_PAGE
    InlineKeyboardMarkup.build(columns: 2) do |kb|
      if page > 0
        kb.callback_button("<< Previous", (page - 1).to_s)
      end

      if page < pages_count - 1
        kb.callback_button("Next >>", (page + 1).to_s)
      end
    end
  end

  @[On(:callback_query)]
  def on_callback_query(client, update)
    if cb = update.callback_query
      if message = cb.message
        page = cb.data.to_s.to_i
        content = get_page(page)
        keyboard = get_keyboard(page)
        message.edit_text(content, reply_markup: keyboard)
      end
    end
  end
end

bot = PaginationBot.new(ENV["API_KEY"])
bot.poll
