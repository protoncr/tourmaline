require "../models"

module Tourmaline::Bot
  # Interfaces with the `CommandMiddleware` to allow the creation
  # of commands.
  module CommandHandler
    # Creates a new command.
    #
    # ```
    # # Creates the commands `/help` and `/start`
    # command(["help", "start"]) do |message|
    #   bot.send_message(message.chat.id, "Hello, world")
    # end
    #
    # # Creates the command `/echo`
    # command("echo") do |message, params|
    #   text = params.join(" ")
    #   bot.send_message(message.chat.id, text)
    #   bot.delete_message(message.chat.id, message.message_id)
    # end
    # ```
    def command(names : String | Array(String), &block : Model::Message ->)
      if commands = middleware.commands
        if names.is_a?(Array)
          names.each do |name|
            name = name[1..-1] if name[0] == "/"
            commands[name] = block
          end
        else
          names = names[1..-1] if names[0] == "/"
          commands[names] = block
        end
      end
    end

    # ditto
    def command(names : String | Array(String), &block : Model::Message, Array(String) ->)
      if commands = middleware.commands
        if names.is_a?(Array)
          names.each do |name|
            name = name[1..-1] if name[0] == "/"
            commands[name] = block
          end
        else
          names = names[1..-1] if names[0] == "/"
          commands[names] = block
        end
      end
    end

    # Removes a command by name.
    def remove_command(name : String)
      commands = middleware.commands
      commands.delete_if { |n| n == name }
    end

    protected def middleware
      @middlewares["Tourmaline::Bot::CommandMiddleware"]?.as(CommandMiddleware)
    end
  end
end
