require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

on_inline_query = Tourmaline::InlineQueryHandler.new(/.*/) do |ctx|
  if query = ctx.inline_query
    results = client.build_inline_query_result do |qr|
      qr.article(
        id: "query",
        title: "Inline title",
        input_message_content: Tourmaline::InputTextMessageContent.new("Click!"),
        description: "Your query: #{query.query}"
      )

      qr.photo(
        id: "photo",
        caption: "Telegram logo",
        photo_url: "https://telegram.org/img/t_logo.png",
        thumbnail_url: "https://telegram.org/img/t_logo.png"
      )

      qr.gif(
        id: "gif",
        gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
        thumbnail_url: "https://telegram.org/img/tl_card_wecandoit.gif"
      )
    end

    ctx.answer_inline_query(results)
  end
end

client.register(on_inline_query)

client.poll
