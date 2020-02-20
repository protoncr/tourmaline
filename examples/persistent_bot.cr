require "../src/tourmaline"
require "../src/tourmaline/persistence/json_persistence"


class PersistentBot < Tourmaline::Client
  include Tourmaline
  include JsonPersistence

  @[Command("seen")]
  def seen_command(ctx)
    users = persisted_users.map(&.[1].id).join('\n')
    ctx.reply(users)
  end

  @[Command("info")]
  def info_command(ctx)
    uid = ctx.text.lstrip('@')
    if i = uid.to_i64?
      uid = i
    end

    if user = get_user(uid)
      message = String.build do |str|
        str.puts user.inline_mention
        str.puts "  id: `#{user.id}`"
        str.puts "  username: `#{user.username}`"
      end
      ctx.reply(message, parse_mode: :markdown)
    else
      ctx.reply("User not found")
    end
  end
end

bot = PersistentBot.new(ENV["API_KEY"])
bot.poll
