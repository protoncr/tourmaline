module Tourmaline
  # Define a new Command. Commands always start with a `/`
  # and should usually be at the beginning of a message.
  # To enforce this behavior use the option `at_start: true`.
  #
  # Example:
  #
  # ```crystal
  # @[Tourmaline::Command("help", at_start: true)]
  # def help_command(message, params)
  #   message.chat.send_message("This is a help message")
  # end
  # ```
  #
  # The command can be a string or an array of strings.
  annotation Command; end

  # Run the annotated method every time a particular `UpdateAction`
  # is fired.
  #
  # Example:
  #
  # ```crystal
  # @[Tourmaline::OnEvent(Tourmaline::UpdateAction::Message)]
  # def on_message(message)
  #   pp message
  # end
  # ```
  annotation On; end
end
