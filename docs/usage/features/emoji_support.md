# Emoji Support

Using emoji in your bot tends to make things a bit less robotic. Here is how you can accomplish
that with Tourmaline.

### Emoji Keyboard

Of course one of the best ways to include emojis in your messages is to just use [an emoji keyboard](https://coolsymbol.com/emojis/emoji-for-copy-and-paste.html) and paste the raw emoji into your messages. Crystal is UTF8 compatible and won't freak out.

```crystal
send_message(message.chat.id, "Hello world 🌎")
```

### emoji.cr

Luckily there is also a great port of [Emoji for Python](https://github.com/carpedm20/emoji) called [emoji.cr](https://github.com/veelenga/emoji.cr). With it you can easily use the same emoji shortcodes Github uses to include emoji in your messages.

```crystal
require "emoji"

# bot definition...

send_message(message.chat.id, Emoji.emojize("Hello world :earth_americas:"))
```

Since `emoji.cr` uses regex to find and replace shortcodes with emoji, it would be a good idea to
put any emoji messages into a constant so that it's not finding and replacing that shortcode every time.