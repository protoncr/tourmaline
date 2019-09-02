module Tourmaline
  # Define a new Command. Commands always start with a `/`
  # and should usually be at the beginning of a message.
  # If you want to allow a command anywhere in a message
  # set the `at_start` option to false.
  #
  # Example:
  #
  # ```crystal
  # @[Command("help")]
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
  # @[On(:message)]
  # def on_message(message)
  #   pp message
  # end
  # ```
  annotation On; end
end
