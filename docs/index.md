---
hide:
  - navigation
  - toc
---

<style>
  .md-content__button {
    display: none;
  }

  .md-content .logo {
    width: 150px;
    display: block;
    margin: 0px auto 20px auto;
  }

  .md-content .md-typeset h1,
  .md-content .md-typeset h2 {
    text-align: center;
    margin: 0;
  }

  .md-content .md-typeset h1 {
    text-align: center;
    margin-bottom: 0.12em;
  }

  .md-content .md-typeset .headerlink {
    display: none;
  }

  .md-content .md-typeset .quickstart {
    display: flex;
    flex-direction: row;
    justify-content: center;
  }
</style>

<img src="./images/logo.svg" class="logo">

<h1>Tourmaline</h1>
<h2>Crystal Telegram Bot Framework</h2>

<hr />

<h2>Quickstart</h2>

<p style="text-align: center;">Tourmaline uses Crystal to communicate with the Telegram Bot API. Therefore to use Tourmaline you should be familiar with how Crystal works.</p>
<p style="text-align: center;">Once inside of a Crystal project, add Tourmaline to your <code>shard.yml</code> file and run <code>shards install</code> to install it.</p>
<p style="text-align: center;">For more information, see the <a href="usage/getting_started">getting started</a> page.</p>

<div class="quickstart">

```crystal
require "tourmaline"
include Tourmaline # To shorten things

bot = Client.new(bot_token: "YOUR_API_TOKEN")

echo_handler = Handlers::CommandHandler.new("echo") do |ctx|
ctx.message.reply(ctx.text)
end

bot.add_event_handler(echo_handler)
bot.poll

```

</div>
