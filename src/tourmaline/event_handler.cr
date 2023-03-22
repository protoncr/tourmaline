module Tourmaline
  alias EventHandlerProc = Proc(Tourmaline::Context, Nil)

  abstract class EventHandler
    abstract def actions : Array(UpdateAction)
    abstract def call(ctx : Tourmaline::Context)
  end

  alias EventHandlerType = EventHandler | EventHandlerProc
end
