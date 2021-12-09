# Frequently Asked Questions

This is an FAQ for Tourmaline, but the answers should be generalized enough to use as a general FAQ for Telegram bots.

### Why isn't my bot responding?

Well first of all, have you programmed it? I know it might sound crazy, but 99% of the people that ask this question didn't actually program their bot. Rather they just created a bot with BotFather and expected things to magically work.

If the answer to that question is "yes", as I hope it is, then there are a few things to try. First of all, make sure you are using the correct API token for the bot you're trying to access. If you have multiple bots it can become pretty easy to accidentally grab the wrong token.

Assuming you have the right token, be sure to check that your bot is actually running and that you have a working internet connection. Try running your bot with the `LOG_LEVEL` environement variable set to `DEBUG` and check the logs. When running in polling mode you should see a whole bunch of calls to `getUpdates`.

If that didn't work, you may need to check if group privacy mode is turned on. Go to BotFather, send the command `/mybots`, select your bot, go to `Bot Settings > Group Privacy > Turn off`. This should only be necessary if your bot is running in groups and you're using non-standard command prefixes, or other handlers like the [HearsHandler][Tourmaline::Handlers::HearsHandler].

Lastly be sure to check the commands you're trying to send. The standard [CommandHandler][Tourmaline::Handlers::CommandHandler] will only respond to commands with the `/` prefix. Also be sure to remember that command names should be unprefixed. For example:

```diff
- @[Command("/echo")]
+ @[Command("echo")]
```

### What messages can my bot see?

Depends partially on whether group privacy mode is turned on or not. As a general rule your bot will not see messages sent by other bots. There is no way around this. If your bot is an admin in the group it will see all messages, except those sent by other bots.

With group privacy mode turned on (the default) you bot will receive:

- Commands explicitly meant for them (e.g., `/command@this_bot`).
- General commands from users (e.g. `/start`) if the bot was the last bot to send a message to the group.
- Messages sent via this bot.
- Replies to any messages implicitly or explicitly meant for this bot.

Additionally all bots, regardless of the group privacy mode will receive:

- All service messages.
- All messages from private chats with users.
- All messages from channels where they are a member.

!!! note
    Eeach particular message can only be available to one privacy-enabled bot at a time, i.e., a reply to bot A containing an explicit command for bot B or sent via bot C will only be available to bot A. Replies have the highest priority.

### Can bots delete messages?

Yes, under 2 conditions:

1. The bot must have the Delete Messages permission
2. The message must be less than 48 hours old

### How can I add my bot to a group?

Same way you add any other user. On the desktop client this can be done by clicking the ellipses in the top right corner while viewing your group, clicking `Info`, and then clicking the `Add` button. If your bot is meant to be added to groups you can make this a bit easier by giving users a link to do so. The URL for the link should be `http://telegram.me/BOT_NAME?startgroup=botstart` where `BOTNAME` is the username of your bot.

### How can I get a user's information?

Bots are not capable of accessing a user's information soley based off of their user id or username, however there are some ways around this. The simplest is to keep a record of each user your bot comes in contact with by watching incoming messages for the user that sent them. An example of this could be as follows:

```crystal
@[On(:message)]
def persist_users(update)
  if message = update.message
    # Convenience method to get all users from a message
    users = message.users
    
    # ... add them to a database
  end
end
```

The one exception to this rule is [chat members][Tourmaline::ChatMember]. If you know the user's id or username and a group that they belong to which your bot also belongs to, you can use [#get_chat_member][Tourmaline::Client::CoreMethods#get_chat_member(chat,user)] to get their [ChatMember][Tourmaline::ChatMember] record.

### I have a question not listed here, where can I ask?

Feel free to join the official [Tourmaline/Proton Chat](https://t.me/protoncr) on Telegram and ask away.