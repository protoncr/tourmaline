require "../src/tourmaline"

class MediaBot < Tourmaline::Client
  ANIMATION_URL_1 = "https://media.giphy.com/media/ya4eevXU490Iw/giphy.gif"
  ANIMATION_URL_2 = "https://media.giphy.com/media/LrmU6jXIjwziE/giphy.gif"
  LOCAL_FILE      = File.expand_path("./cat.jpg", __DIR__)

  @[Command("local")]
  def local_command(ctx)
    ctx.message.reply_with_photo(LOCAL_FILE)
  end

  @[Command("url")]
  def url_command(ctx)
    ctx.message.reply_with_photo("https://picsum.photos/200/300/?#{rand}")
  end

  @[Command("animation")]
  def animation_command(ctx)
    ctx.message.reply_with_animation(ANIMATION_URL_1)
  end

  @[Command("caption")]
  def caption_command(ctx)
    ctx.message.reply_with_photo(
      "https://picsum.photos/200/300/?#{rand}",
      caption: "Caption **text**",
      parse_mode: :markdown
    )
  end

  @[Command("document")]
  def document_command(ctx)
    ctx.message.reply_with_document(LOCAL_FILE)
  end

  @[Command("album")]
  def album_command(ctx)
    ctx.message.reply_with_media_group([
      InputMediaPhoto.new(
        media: "https://picsum.photos/200/500/",
        caption: "From url"
      ),
      InputMediaPhoto.new(
        media: File.expand_path("./cat.jpg", __DIR__),
        caption: "Local"
      ),
    ])
  end

  @[Command("editmedia")]
  def editmedia_command(ctx)
    ctx.message.reply_with_animation(
      ANIMATION_URL_1,
      reply_markup: InlineKeyboardMarkup.build do |kb|
        kb.callback_button("Change media", "swap_media")
      end
    )
  end

  @[OnCallbackQuery("swap_media")]
  def on_swap_media(ctx)
    ctx.query.message.try &.edit_media(InputMediaAnimation.new(ANIMATION_URL_2))
  end
end

bot = MediaBot.new(bot_token: ENV["API_KEY"])
bot.poll
