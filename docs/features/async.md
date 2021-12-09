# Async Handlers

Things aren't async by default in Tourmaline, but that doesn't mean it's not easy to implement. On a base level the body of any method could easily be wrapped in a `spawn` and suddenly that method is async, but it's not a perfect solution.

This is part of the reason I developed the [Async](https://github.com/protoncr/async) library. Using it you can make any function asynchronous just by using the `async` macro. For example:

```crystal
require "async"

# ...

@[Command("echo")]
async def echo_command(ctx)
  ctx.message.reply(ctx.text)
end
```

Nothing else needs to be done, but in the case that you want to call an async method just be sure to `await` the result. You can also call `.wait` on the returned future.