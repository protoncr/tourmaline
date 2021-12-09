# Getting Started with Tourmaline

Time to create your first bot with Tourmaline!

## Installing Tourmaline

This guide assumes that you have Crystal installed and are at least semi-familiar with the syntax. The first thing we are going to need is a fresh Crystal project, so go ahead and run `crystal init app your_bot_name`, making sure to replace "your_bot_name" with whatever you want to call your bot. I'm going to use the famous echo_bot example. Once it's finished, `cd` into the project directory.

Now, open `shard.yml` and add the following lines anywhere in the file (probably at the end):

```yaml linenums="1"
dependencies:
  tourmaline:
    github: protoncr/tourmaline
```

Save the file, and run `shards install`. That's it! Tourmaline is now installed.

## Creating Your Bot

Now it's time to write some code. Open `src/echo_bot.cr` or whatever file was generated for you, and paste in the following code. The code is annotated so you can understand what's going on every step of the way.

```crystal linenums="1"
require "tourmaline" # (1)

class EchoBot < Tourmaline::Client # (2)
  @[Command("echo")] # (3)
  def echo_command(ctx)
    ctx.message.reply(ctx.text) # (4)
  end
end

bot = EchoBot.new(bot_token: ENV["API_KEY"]) # (5)
bot.poll # (6)
```

1. First we have to import Tourmaline into our code. In Crystal this is done with the `require` statement.
2. Next we extend `Tourmaline::Client` and use it to create our own class.
3. In this example we're going to go with the annotation approach to creating bots. Annotations use the `@[Annotation(params)]` syntax and can decorate classes and methods. In this case, we're annotating the `echo_command` method with the `Command` annotation, which turns the method into a command handler.
4. Within the `echo_command` method we're just going to echo whatever the user said back to them, so we use the `reply` method which exists on the `Message` object and send `ctx.text` (the user's message text minus the command) back to them.
5. Almost done. Now we need to create a new instance of our `EchoBot`. Since we extended `Tourmaline::Client` and didn't provide a custom initializer our bot takes the same arguments, so we can provide it with our API Key as an environment variable.
6. The last step is to start our bot. We can do that by "long polling" using the `poll` method.

And that's really all their is to it. Now we can run our code!

```sh
export API_KEY=YOUR_BOT_API_TOKEN
crystal run ./src/echo_bot.cr
```

You should be greeted with a log message in your console telling you that your bot is running, and if you visit your bot on Telegram and run the `/echo` command with some text (eg `/echo hello world`), you should receive a message in reply.