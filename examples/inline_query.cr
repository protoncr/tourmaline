require "../src/tourmaline"

class InlineQueryBot < Tourmaline::Bot
  include Tourmaline

  @[On(:inline_query)]
  def on_inline_query(update)
    if query = update.inline_query
      results = Tourmaline::QueryResultBuilder.build do |builder|
        builder.article(
          id: "query",
          title: "Inline title",
          input_message_content: Tourmaline::InputTextMessageContent.new("Click!"),
          description: "Your query: #{query.query}"
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

      query.answer(results)
    end
  end

  @[On(:inline_query)]
  def on_inline_query(update)
    if query = update.inline_query
      results = [] of Tourmaline::InlineQueryResult

      results << Tourmaline::InlineQueryResultArticle.new(
        id: "query",
        title: "Inline title",
        input_message_content: Tourmaline::InputTextMessageContent.new("Click!"),
        description: "Your query: #{query.query}",
      )

      results << Tourmaline::InlineQueryResultPhoto.new(
        id: "photo",
        caption: "Telegram logo",
        photo_url: "https://telegram.org/img/t_logo.png",
        thumb_url: "https://telegram.org/img/t_logo.png"
      )

      results << Tourmaline::InlineQueryResultGif.new(
        id: "gif",
        gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
        thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
      )

      query.answer(results)
    end
  end
end

bot = InlineQueryBot.new(ENV["API_KEY"])
bot.poll
