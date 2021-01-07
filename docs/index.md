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

bot = EchoBot.new(ENV["API_KEY"])
bot.poll
```