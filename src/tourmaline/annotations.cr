module Tourmaline
  module Annotations
    # Define a new Command. By default all commands start with a `/` and
    # commands are accessable to all chat types. You can change these
    # defaults by supplying named parameters to the annotation.
    #
    # Options:
    #
    # `commands`
    # :    the command(s) to use. should be a prefixless string or symbol.
    #
    # `prefix`
    # :    the prefix for this command. defaults to `/`.
    #
    # `remove_leading`
    # :    if true the `text` value passed to the command context will not include the command, if the command is at the beginning. defaults to `true`.
    #
    # `private_only`
    # :    if true this command will only be allowed inside of private chats.
    #
    # `group_only`
    # :    if true this command will only be allowed inside of groups.
    #
    # Example:
    #
    # ```
    # @[Command("help", prefix: "!", private_only: true)]
    # def help_command(client, update)
    #   update.message.not_nil!.reply("This is a help message")
    # end
    # ```
    annotation Command; end

    # Add a callback query handler which optionally listens for a specific data value.
    #
    # Options:
    #
    # `pattern`
    # :    A `String` or `Regex` which the data must match.
    #
    # Example:
    #
    # ```
    # @[OnCallbackQuery("back")]
    # def back_button_pressed(client, update)
    #   query = update.callback_query.not_nil!
    #   query.answer("You pressed back!")
    # end
    # ```
    annotation OnCallbackQuery; end

    annotation OnChosenInlineResult; end

    annotation Edited; end

    annotation Hears; end

    annotation OnInlineQuery; end

    annotation On; end

    # Catch errors and pass them to the annotated method to be handled.\
    #
    # Options:
    #
    # `*errors`
    # : `Tourmaline::Error` classes that you wish to handle.
    annotation Catch; end
  end
end
