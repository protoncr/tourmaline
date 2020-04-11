require "../src/tourmaline"
require "../src/tourmaline/persistence/json_persistence"


class PersistentBot < Tourmaline::Client
  include JsonPersistence

  @[Command("seen")]
  def seen_command(client, update)
    users = persisted_users.map(&.[1].id).join('\n')
    update.message.try &.reply(users)
  end

  @[Command("info")]
  def info_command(client, update)
    uid = update.context["text"].as_s.lstrip('@')
    if i = uid.to_i64?
      uid = i
    end

    if user = get_user(uid)
      message = String.build do |str|
        str.puts user.inline_mention
        str.puts "  id: `#{user.id}`"
        str.puts "  username: `#{user.username}`"
      end
      update.message.try &.reply(message, parse_mode: :markdown)
    else
      update.message.try &.reply("User not found")
    end
  end
end

bot = PersistentBot.new(ENV["API_KEY"])
bot.poll
