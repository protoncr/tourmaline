# Introduction

Bots are the figurative workhorses of Telegram's platform, allowing for everything from group management to file conversion and more; but how does one make a bot? Well that is the question I aim to answer in this brief introduction. If you already know how to make a bot, and would like to focus more on how to make a bot with Tourmaline, feel free to skip to the [Getting Started](./getting_started.md).

## The BotFather

Every journey has to start somewhere, and for the would-be Telegram bot developer that is [BotFather](https://t.me/BotFather). BotFather itself is a Telegram bot which allows you to create and manage your own bots. As is convention, you can start BotFather by starting a conversation and pressing the "Start" button or sending the `/start` command.

To create a new bot, just send the `/newbot` command. BotFather will then ask a couple questions which sometimes confuse people.

> Alright, a new bot. How are we going to call it? Please choose a name for your bot."

The first question is asking for the screen name of your bot. This is the name that will appear when it sends messages and __not__ its username.

> Good. Now let's choose a username for your bot. It must end in `bot`. Like this, for example: TetrisBot or tetris_bot.

Now _this_ is your bot's username. As it states, your bot's username __must__ end with the word "bot". Capitalization doesn't matter, but ending with the word "bot" is pertinant.

I won't go into more detail as to how to setup a bot here as you can just run `/help` to see all of the available commands, but once you finish the bot creation you will be presented with an API Token. __KEEP THIS SAFE__. Your token is for your eyes and your eyes only, as anyone with half a brain can take your token and use it to control your bot maliciously. We will also need this token later, so keep it handy.

## Running Your Bot

A bot is nothing more than code running on a computer somewhere. In most cases during development and testing that computer will probably be your own, but what happens when you're ready to share your bot with the world? At that point, running your bot on your own local machine isn't the best idea. Personal computers need to sleep, be restarted every now and then, and have more important jobs than hosting a bot 24/7.

__Enter the VPS.__

If you already have a server on which to run your bot, or are at least familiar with how to deploy your bot elsewhere you can probably skip this section. For anyone left remaining, you need a server. Far and away the most affordable method of getting your own server is by using a VPS, or virtual private server. Providers like AWS, DigitalOcean, Vultr, and Hetzner (my personal favorite) provide these for as little as $2-5/mo.

To use a VPS you will need some knowledge of Linux, including how to use `ssh` to remotely access a server. If Linux is foreign to you I highly recommend getting aquainted, as it's going to be very important going forward. We will go into more detail about how to actually run your bot on your VPS later in this guide.

## Avoiding Limits

Telegram bots are heavily limited in what they can, and cannot do. The good news is that these limits are mostly documented when it comes to bots, so avoiding them is completely in your control. For more information on the current limits I recommend reading ["My bot is hitting limits, how do I avoid this?"](https://core.telegram.org/bots/faq#my-bot-is-hitting-limits-how-do-i-avoid-this) from the Telegram FAQ.