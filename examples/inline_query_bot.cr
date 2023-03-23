require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

on_inline_query = Tourmaline::InlineQueryHandler.new(/.*/) do |ctx|
  if query = ctx.inline_query
    results = Tourmaline::InlineQueryResult.build do
      article(
        id: "query",
        title: "Inline title",
        input_message_content: Tourmaline::InputTextMessageContent.new("Click!"),
        description: "Your query: #{query.query}"
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

    ctx.answer_query(results)
  end
end

client.register(on_inline_query)

client.poll
