require "../src/tourmaline"
require "../src/tourmaline/persistence/json_persistence"

class PersistentBot < Tourmaline::Client
  @[Command("seen")]
  def seen_command(ctx)
    users = @persistence.as(JsonPersistence).persisted_users.map(&.[1].id).join('\n')
    ctx.message.reply(users)
  end

  @[Command("info")]
  def info_command(ctx)
    uid = ctx.text.lstrip('@')
    if i = uid.to_i64?
      uid = i
    end

    if user = @persistence.get_user(uid)
      message = String.build do |str|
        str.puts user.inline_mention
        str.puts "  id: `#{user.id}`"
        str.puts "  username: `#{user.username}`"
      end
      ctx.message.reply(message, parse_mode: :markdown)
    else
      ctx.message.reply("User not found")
    end
  end
end

bot = PersistentBot.new(ENV["API_KEY"], persistence: Tourmaline::JsonPersistence.new)
bot.poll
