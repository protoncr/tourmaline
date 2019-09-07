require "../src/tourmaline"

class InlineQueryBot < Tourmaline::Bot
  include Tourmaline

  @[On(:inline_query)]
  def on_inline_query(update)
    query = update.inline_query.not_nil!
    results = [] of Tourmaline::Model::InlineQueryResult

    results << Tourmaline::Model::InlineQueryResultArticle.new(
      id: "query",
      title: "Inline title",
      input_message_content: Tourmaline::Model::InputTextMessageContent.new("Click!"),
      description: "Your query: #{query.query}",
    )

    results << Tourmaline::Model::InlineQueryResultPhoto.new(
      id: "photo",
      caption: "Telegram logo",
      photo_url: "https://telegram.org/img/t_logo.png",
      thumb_url: "https://telegram.org/img/t_logo.png"
    )

    results << Tourmaline::Model::InlineQueryResultGif.new(
      id: "gif",
      gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
      thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
    )

    answer_inline_query(query.id, results)
  end
end

bot = InlineQueryBot.new(ENV["API_KEY"])
bot.poll
