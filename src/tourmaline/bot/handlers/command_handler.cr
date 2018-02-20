require "../types"

module Tourmaline::Bot
  module CommandHandler

    def command(names : String | Array(String), &block : Message ->)
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

    def command(names : String | Array(String), &block : Message, Array(String) ->)
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

    def remove_command(name : String)
      commands = middleware.commands
      commands.delete_if { |n| n == name }
    end

    protected def middleware
      @middlewares["Tourmaline::Bot::CommandMiddleware"]?.as(CommandMiddleware)
    end

  end
end
