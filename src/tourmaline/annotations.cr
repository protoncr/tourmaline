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
  # @[OnCallbackQuery("button_click")]
  # def on_button_click(ctx)
  #   pp ctx.update_action
  # end
  # ```
  annotation OnCallbackQuery; end

  # Run the annotated method when a matching chosen_inline_result is found, passing
  # in a `Context` object.
  #
  # Example:
  #
  # ```crystal
  # @[OnChosenInlineResult(id: "gif")]
  # def on_chosen_result(ctx)
  #   pp ctx.result
  # end
  # ```
  annotation OnChosenInlineResult; end

  # Run the annotated method when a matching inline_query is found, passing
  # in a `Context` object.
  #
  # Example:
  #
  # ```crystal
  # @[OnInlineQuery(id: "foo")]
  # def on_inline_foo(ctx)
  #   pp ctx.inline_query
  # end
  # ```
  annotation OnInlineQuery; end
end
