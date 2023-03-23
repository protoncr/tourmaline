require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

ANIMATION_URL_1 = "https://media.giphy.com/media/ya4eevXU490Iw/giphy.gif"
ANIMATION_URL_2 = "https://media.giphy.com/media/LrmU6jXIjwziE/giphy.gif"
LOCAL_FILE      = File.expand_path("./cat.jpg", __DIR__)

local_command = Tourmaline::CommandHandler.new("local") do |ctx|
  ctx.reply_with_photo(LOCAL_FILE)
end

url_command = Tourmaline::CommandHandler.new("url") do |ctx|
  ctx.reply_with_photo("https://picsum.photos/200/300/?#{rand}")
end

animation_command = Tourmaline::CommandHandler.new("animation") do |ctx|
  ctx.reply_with_animation(ANIMATION_URL_1)
end

caption_command = Tourmaline::CommandHandler.new("caption") do |ctx|
  ctx.reply_with_photo(
    "https://picsum.photos/200/300/?#{rand}",
    caption: "Caption **text**",
    parse_mode: :markdown
  )
end

document_command = Tourmaline::CommandHandler.new("document") do |ctx|
  ctx.reply_with_document(LOCAL_FILE)
end

album_command = Tourmaline::CommandHandler.new("album") do |ctx|
  ctx.reply_with_media_group([
    Tourmaline::InputMediaPhoto.new(
      media: "https://picsum.photos/200/500/",
      caption: "From url"
    ),
    Tourmaline::InputMediaPhoto.new(
      media: File.expand_path("./cat.jpg", __DIR__),
      caption: "Local"
    ),
  ])
end

editmedia_command = Tourmaline::CommandHandler.new("editmedia") do |ctx|
  ctx.reply_with_animation(
    ANIMATION_URL_1,
    reply_markup: Tourmaline::InlineKeyboardMarkup.build do |kb|
      kb.callback_button("Change media", "swap_media")
    end
  )
end

on_swap_media = Tourmaline::CallbackQueryHandler.new("swap_media") do |ctx|
  ctx.with_message do |msg|
    ctx.client.edit_message_media(msg.chat, message: msg, media: Tourmaline::InputMediaAnimation.new(ANIMATION_URL_2))
  end
end

client.register(local_command, url_command, animation_command, caption_command, document_command, album_command, editmedia_command, on_swap_media)

client.poll
