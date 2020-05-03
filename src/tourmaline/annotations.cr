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
  # def help_command(message, params)
  #   send_message(message.chat.id, "This is a help message")
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
