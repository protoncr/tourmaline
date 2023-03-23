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

client = Tourmaline::Client.new(ENV["BOT_TOKEN"]) # (2)

echo_handler = Tourmaline::CommandHandler.new("echo") do |ctx| # (3)
  text = ctx.text.to_s
  ctx.reply(text) unless text.empty? # (4)
end

client.register(echo_handler) # (5)

client.poll # (6)
```

1. First we have to import Tourmaline into our code. In Crystal this is done with the `require` statement.
2. Next we create a new `Client` object. This is the main object that we will be using to interact with the Telegram Bot API. Into the `Client` we pass our bot's API token, which we will be getting from the BotFather. We will be storing this in an environment variable, so we use `ENV["BOT_TOKEN"]` to get the value of the `BOT_TOKEN` environment variable. If you are not familiar with environment variables, you can read more about them [here](https://en.wikipedia.org/wiki/Environment_variable).
3. Tourmaline uses a system of handlers to handle different types of events. In this case we are creating a `CommandHandler` which will handle the `/echo` command. The first argument to the `CommandHandler` is the name of the command, and the second argument is a block of code that will be executed when the command is received. The block of code is passed a `Context` object, which contains information about the command and the message that triggered it.
4. The `Context` object has a `text` property which contains the text of the message that triggered the command. We can use this to get the text of the message and reply with it. We use the `reply` method to send a message back to the chat that the command was sent in. We also check to make sure that the message isn't empty, because if the user just sends `/echo` without any text, the message will be empty.
5. Now that we have created our handler, we need to register it with the `Client` so that it can be used. This is done with the `register` method.
6. Finally, we call the `poll` method on the `Client` to start the bot. This method will block the current thread, so it is important that you call it at the end of your code.

And that's really all their is to it. Now we can run our code!

```sh
export LOG_LEVEL=info # by default you won't see any logs, so we set the log level to info
export BOT_TOKEN=YOUR_BOT_API_TOKEN
crystal run ./src/echo_bot.cr
```

If all goes well, you should see something like this:

```sh
2023-03-23T00:17:53.778090Z   INFO - tourmaline.poller: Polling for updates...
```