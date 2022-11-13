require "../src/tourmaline"

class InlineQueryBot < Tourmaline::Client
  @[OnInlineQuery("")]
  def on_inline_query(ctx)
    results = InlineQueryResult.build do
      article(
        id: "query",
        title: "Inline title",
        input_message_content: InputTextMessageContent.new("Click!"),
        description: "Your query: #{ctx.query.query}"
      )

      photo(
        id: "photo",
        caption: "Telegram logo",
        photo_url: "https://telegram.org/img/t_logo.png",
        thumb_url: "https://telegram.org/img/t_logo.png"
      )

      gif(
        id: "gif",
        gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
        thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
      )
    end

    ctx.query.answer(results)
  end
end

bot = InlineQueryBot.new(bot_token: ENV["API_KEY"])
bot.poll
