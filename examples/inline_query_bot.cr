require "../src/tourmaline"

class InlineQueryBot < Tourmaline::Client
  @[OnInlineQuery]
  def on_inline_query(ctx)
    results = QueryResultBuilder.build do |builder|
      builder.article(
        id: "query",
        title: "Inline title",
        input_message_content: InputTextMessageContent.new("Click!"),
        description: "Your query: #{ctx.query}"
      )

      builder.photo(
        id: "photo",
        caption: "Telegram logo",
        photo_url: "https://telegram.org/img/t_logo.png",
        thumb_url: "https://telegram.org/img/t_logo.png"
      )

      builder.gif(
        id: "gif",
        gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
        thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
      )
    end

    ctx.answer(results)
  end
end

bot = InlineQueryBot.new(ENV["API_KEY"])
bot.poll
