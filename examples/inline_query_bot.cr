require "../src/tourmaline"

class InlineQueryBot < Tourmaline::Client
  @[On(:inline_query)]
  def on_inline_query(client, update)
    results = QueryResultBuilder.build do |builder|
      builder.article(
        id: "query",
        title: "Inline title",
        input_message_content: InputTextMessageContent.new("Click!"),
        description: "Your query: #{update.inline_query.try &.query}"
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

    update.inline_query.try &.answer(results)
  end
end

bot = InlineQueryBot.new(ENV["API_KEY"])
bot.poll
