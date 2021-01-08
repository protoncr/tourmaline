# Getting Started with Tourmaline

So you want a Telegram bot, you like clean code and powerful frameworks, and you don't want to spend forever combing through complex documentation trying to figure out how to get started. Well you've come to the right place!

Tourmaline is a Telegram bot framework for those that like things fast, efficient, and beautiful, which is why it's written in [Crystal](https://crystal-lang.org). But enough talk, this is a getting started guide, not a biography.

## Installation

First be sure you have Crystal installed. This is a Crystal framework, and won't work otherwise. Unfortunately this means (for now) you Windows people are going to have to run this using WSL or a virtual machine.

Initialize your new Crystal project, for the purposes of this example we'll call our project `echo_bot`, but you can call yours whatever you like. To create the new project, run `crystal init app echo_bot` (replacing `echo_bot` with the name you'd like for your project).

Change directories into your new project (using `cd echo_bot` in our case here). If you're unfamiliar with Crystal I highly recommend checking out [the official docs](https://crystal-lang.org/reference/using_the_compiler/index.html#creating-a-crystal-project) to get an idea of the project structure, from now on it will be assumed that you understand the basics of a Crystal project.

Now to install Tourmaline. Open up `shard.yml` and add the following snippet:

```yaml
dependencies:
  tourmaline:
    github: protoncr/tourmaline
```

Then in your terminal run `shards install`. Tourmaline should now be installed!

## Register Your Bot

All bot registration in Telegram is facilitated through [@BotFather](https://t.me/BotFather). Don't confuse _registration_ with _creation_ though. BotFather simply helps you tell Telegram about, and manage your bot. We still need to write some code for the bot to function.

Head on over to [t.me/BotFather](https://t.me/BotFather). Just in case this is your first time using a Telegram bot, let's go over some basics.

1. Bots are {++NOT++} users. The operate by a specific set of rules, most of which don't apply to standard user accounts.

2. Most bots are controlled by using {++bot commands++}. Officially, bot commands begin with a `/` and can contain any of the characters `[a-zA-Z_]`, additionally an `@` can be used to differentiate between bots in a group.

3. Bots cannot send messages to users that did not start a conversation with them first. This is a spam prevention measure.

4. By default bots will be in group privacy mode. This means that they will only be able to see messages that start with a bot command until this is turned off. This only applies to groups, in private they can see everything.

There are plenty of other things to know, but those are some of the more important ones. Now let's get on to using BotFather to register a bot!

First send the `/help` command. Whenever using a new bot it's always a good idea to see if they respond to this command, and what help is available. In our case we can see in the BotFather help that we can run `/newbot` to create (register) a new bot.

The `/newbot` command will ask for a name. This will be the screen name of your bot, not the username, so feel free to call it whatever you want.

Next it will ask for a username. This must be unique, can only contain alphanumeric characters and underscores, and must be at least 5 characters long (3 and 4 character usernames are reserved for Telegram internal use).

Once you've entered a valid username it will send you a message containing some instructions and an API token that looks something like this `123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ`. {++KEEP THIS SECRET!++} Anyone with access to this token will be able to control your bot, so don't share it.

Now if you send the `/mybots` command you should see your bot listed. Click it to enter the configuration menu for your bot. You can explore the options here if you wish, but we'll be moving on now.

## Example Project

We're going to be making a really simple echo bot for this example, hence the project name `echo_bot`. Go head and open the generated file at `src/echo_bot.cr` and paste in the following code. Don't worry, we'll go over each line in detail afterwards.

!!! tip
    This is exactly the same as the [echo bot](https://github.com/protoncr/tourmaline/blob/master/examples/echo_bot.cr) example in the source repo. If anything is broken be sure to check there for an updated code snippet.

```crystal linenums="1"
require "tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.message.reply(ctx.text)
  end
end

bot = EchoBot.new("YOUR_API_TOKEN")
bot.poll
```

Be sure to replace `YOUR_API_TOKEN` with the token you received from BotFather. Now run the bot with `crystal run ./src/echo_bot.cr`. Now if you visit your bot in Telegram and run `/echo some message` it should relpy to you with the message you sent. Congrats! You just created your first bot.

Now let's break this code down line by line, starting from line 3 since the `require` should be obvious enough.

```crystal
class EchoBot < Tourmaline::Client
  # ...
end
```

This is just defining our bot, `EchoBot`, as a sublcass of `Tourmaline::Client`. This gives us access to everything that `Tourmaline::Client` has, as well as allowing us to use the `Command` annotation which we'll take a look at next.

```crystal
  @[Command("echo")]
  def echo_command(ctx)
    # ...
  end
```

`@[Constant()]` is the annotation invokation syntax. Annotations, much like in languages like Python and Typescript, can be used to modify the annotated method, class, variable, etc.. In this case it registers the method as an event handler for commands specifically (see `Tourmaline::Handlers::CommandHandler`). The `ctx` property that gets passed into the command is an instance of `Tourmaline::Handlers::CommandHandler::Context`.

```crystal
    ctx.message.reply(ctx.text)
```

This is pretty simple. The [context][Tourmaline::Handlers::CommandHandler::Context] has a `message` property, which is the [message][Tourmaline::Message] that contains the command we're acting on. All we're doing is replying to the message with the text that was in the message (minus the bot command).

```crystal
bot = EchoBot.new("YOUR_API_TOKEN")
bot.poll
```

Finally we create a new instance of our `EchoBot` with our API token, and start it in [polling mode][Tourmaline::Client::CoreMethods#poll(delete_webhook)].