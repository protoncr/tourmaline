module Tourmaline::Listeners
  @[ADI::Register]
  struct CommandListener
    include AED::EventListenerInterface

    @[AEDA::AsEventListener(priority: 50)]
    def on_command(command : Tourmaline::Events::Command)
      pp command
    end
  end
end
