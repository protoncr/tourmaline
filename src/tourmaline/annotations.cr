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
  #   send_message(message.chat.id, "This is a help message")
  # end
  # ```
  #
  # The command can be a string or an array of strings.
  annotation Command; end

  # Similar to `Command`, `Hears` is a more general pattern matcher.
  # Any time a message matches a pattern defined inside of a
  # `Hears` annotation the annotated method will be fired.
  #
  # Example:
  #
  # ```crystal
  # @[Hears(/^Hello/)]
  # def respond_to_hello(message)
  #   send_message(message.chat.id, "Hello to you", respond_to_message: message.message_id)
  # end
  #
  # The pattern can be a string, regex, or an array of string/regex.
  annotation Hears; end

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

  # Run the annotated method when a matching callback_query is found, passing
  # in a `Context` object.
  #
  # Example:
  #
  # ```crystal
  # @[CallbackQuery("button_click")]
  # def on_button_click(ctx)
  #   pp ctx.update_action
  # end
  # ```
  annotation CallbackQuery; end
end
