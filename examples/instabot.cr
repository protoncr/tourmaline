require "../src/tourmaline"

class InstaBot < Tourmaline::Client
  START_TEXT = <<-TEXT
  Welcome to InstaBot. I can be used to download photos and videos from Instagram posts.

  Just send me a link in the format `https://instagram.com/p/POST_ID` and I'll download them for you.

  Created by @watzon
  TEXT

  @[Command("start")]
  def start_command(ctx)
    ctx.message.respond(START_TEXT, parse_mode: :markdown)
  end

  @[Hears(/instagram\.com\/p\/([\w\d]+)\/?/)]
  def on_insta_link(ctx)
    post_url = ctx.match[0]
    post_url = "https://www." + post_url.rstrip('/') + "/?__a=1"

    response = HTTP::Client.get(post_url)
    json = JSON.parse(response.body)

    if json.as_h.empty?
      return ctx.message.respond("I only work with public posts (for now at least)")
    end

    if video_url = json.dig?("graphql", "shortcode_media", "video_url")
      ctx.message.chat.send_chat_action(:upload_video)
      return ctx.message.respond_with_video(video_url.as_s)
    elsif display_url = json.dig?("graphql", "shortcode_media", "display_url")
      ctx.message.chat.send_chat_action(:upload_photo)
      return ctx.message.respond_with_photo(display_url.as_s)
    else
      return ctx.message.respond("That post doesn't seem to be supported")
    end
  end
end

bot = InstaBot.new(ENV["API_KEY"])
bot.poll
