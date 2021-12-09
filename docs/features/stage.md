# Stage

Stages, sometimes also called wizards or conversations, are a simple way to add a bit of life to your bot. They allow you to send input and wait for feedback before proceeding. For example, say your bot was being used to register a user for a service. You could ask questions like _"What is your full name?"_ or _"Would you have expected the Spanish Inquisition?"_ and receive responses.

In Tourmaline the [Stage][Tourmaline::Stage] class tries to mock `Tourmaline::Client` as closely as possible, while providing an additional annotation called [Step][Tourmaline::Stage::Step]. Let's take a look at how a simple Stage might look:

```crystal linenums="1"
class NameAsker(String) < Stage(T)
  @[Step(:name, initial: true)]
  def ask_name(client)
    send_message(self.chat_id, "What is your name?")

    # in will be passed to this block.
    self.await_response do |ctx|
      self.context = ctx.text
      self.exit
    end
  end
end

class MyBot < Tourmaline::Client
  @[Command("start")]
  def start_command(ctx)
    stage = NameAsker.enter(self, chat_id: ctx.message.chat_id, context: "")
    stage.on_exit do |name|
      ctx.message.respond("You entered #{name}")
    end
  end
end
```

## Steps

Stages are composed of steps which are created either with [Stage#on][Tourmaline::Stage#on(step,initial,&)] or with the [Step][Tourmaline::Stage::Step] annotation. If a step is tagged with `initial: true` it will be the first step in the series. If no step is tagged with `initial: true` you will have to manually transition to the step you want to start with by using [Stage#transition][Tourmaline::Stage#transition(event)].

!!! note
    The main caviat, and it's a small one, is that you must either transition or exit from a step. If you don't your program will be stuck in a sort of limbo.

Here is an example of a simple transition:

```crystal
@[Step(:name, initial: true)]
def ask_name(client)
  send_message(self.chat_id, "What is your name?")

  self.await_response do |ctx|
    self.context.name = ctx.text
    self.transition :age
  end
end

@[Step(:age)]
def ask_age(client)
  send_message(self.chat_id, "How about your age?")

  self.await_response do |ctx|
    self.context.age = ctx.age
    self.exit
  end
end
```

For a more example of Stage use, see [examples/stage_bot.cr](https://github.com/protoncr/tourmaline/blob/master/examples/stage_bot.cr).