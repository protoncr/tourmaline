module Tourmaline
  # Define a new Command. By default all commands start with a `/` and
  # commands are accessable to all chat types. You can change these
  # defaults by supplying named parameters to the annotation.
  #
  # Options:
  #
  # - `prefix` - the prefix for this command. defaults to `/`.
  # - `anywhere` - if true, this command will be parsed anywhere inside of a message, not just at the beginning. defaults to `false`.
  # - `remove_leading` - if true the `text` value passed to the command context will not include the command, if the command is at the beginning. defaults to `true`.
  # - `private_only` - if true this command will only be allowed inside of private chats.
  # - `group_only` - if true this command will only be allowed inside of groups.
  #
  # Example:
  #
  # ```crystal
  # @[Command("help", prefix: "!", private_only: true)]
  # def help_command(client, update)
  #   update.message.not_nil!.reply("This is a help message")
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

  # Add a callback query handler which optionally listens for a specific data value.
  #
  # Options:
  #
  # - `pattern` - A String or Regex which the data must match.
  #
  # Example:
  #
  # ```crystal
  # @[OnCallbackQuery("back")]
  # def back_button_pressed(client, update)
  #   query = update.callback_query.not_nil!
  #   query.answer("You pressed back!")
  # end
  # ```
  #
  # The command can be a string or an array of strings.
  annotation OnCallbackQuery; end
end
