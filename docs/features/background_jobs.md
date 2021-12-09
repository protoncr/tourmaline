# Background Jobs

Sometimes you want to do something at a specific time, or interval. These "tasks" are usually called background jobs. Luckily there are a couple of libraries that make background job handling super easy!

### Tasker

[Tasker](https://github.com/spider-gazelle/tasker) is a great CRON type scheduler for Crystal. It uses fibers to create in-memory background jobs that either run at a specific time, or at a specific interval. Let's look at a simple example bot which posts to a channel at a specific interval:

```crystal
require "tasker"
require "tourmaline"

CHANNEL_ID = 00000000000

class PostBot < Tourmaline::Client
  def post_to_channel
    # Fetch something from a database
    send_message(CHANNEL_ID, content)
  end
end

bot = PostBot.new(bot_token: ENV["API_KEY"])

# Grab the default Tasker instance
schedule = Tasker.instance

schedule.every(5.minutes) do 
  bot.post_to_channel
end

bot.poll
```

### Mosquito

[Mosquito](https://github.com/robacarp/mosquito) is a bit more advanced than Tasker and uses a Redis backend to keep track of jobs. It comes with two different job types:

`QueuedJob`
: a job that gets inserted into a queue and processed sequentially. Queued jobs can be rate limited so that only _N_ number of jobs are performed every _X_ amount of time. This can be really useful if you want to use a request that is heavily rate limited by Telegram, such as `send_contact`.

`PeriodicJob`
: a job that runs accoding to a predefined schedule. They can be used just like the above Tasker example to perform a task at specific intervals.

Let's see the above example, but with Mosquito:

```crystal
require "mosquito"
require "tourmaline"

CHANNEL_ID = -10000000000

class PostBot < Tourmaline::Client
  def post_to_channel
    # Fetch something from a database
    send_message(CHANNEL_ID, content)
  end
end

# Bot needs to be a constant so we can access it. Obviously
# there are better ways to do this with a proper project setup
BOT = PostBot.new(bot_token: ENV["API_KEY"])

# The job will be automatically queued as it's made
class MyJob < Mosquito::PeriodicJob
  run_every 5.minutes

  def perform
    BOT.post_to_channel
  end
end

# We need to spawn the Mosquito runner
spawn do
  Mosquito::Runner.start
end

bot.poll
```