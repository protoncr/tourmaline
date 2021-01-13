# Handlers

Tourmaline is built around the concept of `Handlers`, each of which is modeled to handle a specific kind of input. For instance, the [CommandHandler](Tourmaline::Handlers::CommandHandler) is specifically designed to handle bot commands. Each handler also has a corresponding annotation. For instance, [Command][Tourmaline::Annotations::Command].

There are currently **{{ crystal.lookup('Tourmaline::Handlers').types | length }}** types of handler built in:

{% for typ in crystal.lookup('Tourmaline::Handlers').types %}
- [{{typ.name}}][{{typ.abs_id}}]
{% endfor %}

For the purposes of this document we'll be focusing on the CommandHandler, since it's the one you're most likely to use most often, but you can find specific documentation for each handler type on their API reference page.

## The Command Handler

Most, though not all, bots respond to commands. Commands are a form of message which start (unless otherwise specified) with a forward slash (`/`). A simple example of a command is probably one of the most common. `/start`.

`/start` is the universal bot initialization command in Telegram, because whenever someone goes to your bot for the first time this is the command that's going to be sent. In most cases you'll see this command being used to welcome a user to your bot, explain what the bot does, and maybe do some analytics in the backend.

A very basic start command might look like this:

```crystal
@[Command("start")]
def start_command(ctx)
  ctx.message.reply("Welcome to my bot")
end
```

Commands have the ability to get very complex though. For instance, you could have the `/start` command and the `/help` command be the same thing. This is somewhat common for smaller bots with less commands.

```crystal
@[Command(["start", "help"])]
def start_command(ctx)
  # ...
end
```

You can also set custom prefixes for your commands. For instance, it's also common to use `!` as an additional prefix.


```crystal
@[Command(["start", "help"], prefix: ["/", "!"])]
def start_command(ctx)
  # ...
end
```

You can even stack handlers if you so wish, just be sure to do some type checking.

```crystal
@[Hears(/^how do i/)]
@[Command(["start", "help"], prefix: ["/", "!"])]
def start_command(ctx)
  # Both handlers have a `#message` property, so this is safe
  message = ctx.message
  # ...
end
```

## Handlers Without Annotations

While annotations are the preferred way to invoke handlers, they aren't the only way. Sometimes you may wish to dynamically generate handlers, or you may be use to a library like Python-Telegram-Bot and prefer to add handlers to your bot instance using a more functional approach.

Here's an example of a `/start` command added using this method:

```crystal
# This makes things less verbose
include Tourmaline

bot = Client.new("YOUR_API_TOKEN")
bot.add_handler CommandHandlers.new("start") do |ctx|
  ctx.message.reply("Welcome to my bot)
end
```

And that's all there is to it! Which you prefer is, of course, your choice. In truth, as we'll see below, handlers are just syntactic sugar around this exact methodology.

## Handler Groups

All handlers have a property called `group` which is normally set to `:default`. Groups allow us to make sure that only one handler responds to any given update, unless otherwise specified. In most cases you'll want to just leave this property alone, but in the case that you do want multiple handlers to respond to incoming updates all you have to do is set `group` to something unique. For example:

```crystal
@[On(:update, group: :persist_users)]
def persist_users(update)
  # ...
end

@[Command("help")]
def help_command(ctx)
  # ...
end
```

In the above example if we didn't have the `group` set in the first handler the second handler would never get called.

## Custom Handlers

You can also create custom handlers if you want. Let's create a simple `PhotoHandler` as an example:

{% raw %}
```crystal linenums="1"
annotation OnPhoto; end

class PhotoHandler < Tourmaline::EventHandler
  # This is needed for the macro which registers the handler
  # to know which annotation belongs to it.
  ANNOTATION = OnPhoto

  # All handlers need at least these 3 things in their initialize method
  def initialize(group = :default priority = 0, &block : Context ->)
    super(group, priority)
    @proc = block
  end

  # All handlers also need a `call` method. This gets called on every Update,
  # unless another handler with the same group gets called first.
  def call(client : Client, update : Update)
    if message = update.message
      return unless message.photo.size > 0
      
      ctx = Context.new(update, message, message.photo)
      @proc.call(ctx)

      # returning true lets other handlers in the same group know not to respond
      true
    end
  end

  # Handlers with an annotation also need a Context object. This can be a class, struct,
  # or an alias to another type. All that matters is that it exists.
  record Context, update : Update, message : Message, photos : Array(PhotoSize)
end
```
{% endraw %}

For more advanced handler logic, be sure to check the source for each of the existing handlers.