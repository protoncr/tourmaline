require "../src/tourmaline"

bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])

bot.on(Tourmaline::Bot::UpdateAction::InlineQuery) do |update|
  query = update.inline_query.not_nil!
  results = [] of Tourmaline::Bot::Model::InlineQueryResult

  results << Tourmaline::Bot::Model::InlineQueryResultArticle.new(
    id: "query",
    title: "Inline title",
    input_message_content: Tourmaline::Bot::Model::InputTextMessageContent.new("Click!"),
    description: "Your query: #{query.query}",
  )

  results << Tourmaline::Bot::Model::InlineQueryResultPhoto.new(
    id: "photo",
    caption: "Telegram logo",
    photo_url: "https://telegram.org/img/t_logo.png",
    thumb_url: "https://telegram.org/img/t_logo.png"
  )

  results << Tourmaline::Bot::Model::InlineQueryResultGif.new(
    id: "gif",
    gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
    thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
  )

  bot.answer_inline_query(query.id, results)
end

bot.poll
