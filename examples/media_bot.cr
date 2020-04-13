require "../src/tourmaline"

class MediaBot < Tourmaline::Client
  AnimationUrl1 = "https://media.giphy.com/media/ya4eevXU490Iw/giphy.gif"
  AnimationUrl2 = "https://media.giphy.com/media/LrmU6jXIjwziE/giphy.gif"
  LocalFile = File.expand_path("./cat.jpg", __DIR__)

  @[Command("local")]
  def local_command(client, update)
    update.message.try &.reply_with_photo(LocalFile)
  end

  @[Command("url")]
  def url_command(client, update)
    update.message.try &.reply_with_photo("https://picsum.photos/200/300/?#{rand}")
  end

  @[Command("animation")]
  def animation_command(client, update)
    update.message.try &.reply_with_animation(AnimationUrl1)
  end

  @[Command("caption")]
  def caption_command(client, update)
    update.message.try &.reply_with_photo(
      "https://picsum.photos/200/300/?#{rand}",
      caption: "Caption **text**",
      parse_mode: :markdown
    )
  end

  @[Command("document")]
  def document_command(client, update)
    update.message.try &.reply_with_document(LocalFile)
  end

  @[Command("album")]
  def album_command(client, update)
    update.message.try &.reply_with_media_group([
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
  def editmedia_command(client, update)
    update.message.try &.reply_with_animation(
      AnimationUrl1,
      reply_markup: Markup.inline_buttons([
        Markup.callback_button("Change media", "swap_media"),
      ]).inline_keyboard
    )
  end

  @[OnCallbackQuery("swap_media")]
  def on_swap_media(client, update)
    update.message.try &.edit_media(InputMediaAnimation.new(AnimationUrl2))
  end
end

bot = MediaBot.new(ENV["API_KEY"])
bot.poll
