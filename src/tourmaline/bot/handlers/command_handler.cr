require "../types"

module Tourmaline::Bot
  module CommandHandler

    macro included
      @commands = {} of String => (Message ->) | (Message, Array(String) ->)
    end

    def command(names : String | Array(String), &block : Message ->)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          @commands[name] = block
        end
      else
        names = names[1..-1] if names[0] == "/"
        @commands[names] = block
      end
    end

    def command(names : String | Array(String), &block : Message, Array(String) ->)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          @commands[name] = block
        end
      else
        names = names[1..-1] if names[0] == "/"
        @commands[names] = block
      end
    end

    def remove_command(name : String)
      @@commands.delete_if { |n| n == name }
    end

    def call(cmd : String, message : Message, params : Array(String))
      if proc = @commands[cmd]?
        if proc.is_a?(Message ->)
          proc.call(message)
        else
          proc.call(message, params)
        end
      else
        raise "The command `#{cmd}` doesn't exist"
      end
    end

    protected def add_command_handler
      use do |update|
        if message = update.message
          if entities = message.entities
            entities.each do |entity|
              if entity.type == "bot_command" && entity.offset == 0
                message_text = message.text.not_nil!

                # Get the command value
                command_name = message_text[1..entity.length - 1]

                # Check if the command has the bot's name attached
                if command_name.includes?("@")
                  pieces = command_name.split("@")
                  if pieces[1] != @bot_name
                    next
                  end

                  command_name = pieces[0]
                end

                # Check the command against the commands hash
                if @commands.has_key?(command_name)
                  command = @commands[command_name]

                  if command.is_a?(Message ->)
                    command.call(message)
                  else
                    rest = message_text[entity.length..-1]
                    params = rest.split(" ")
                    command.call(message, params)
                  end
                end
              end
            end
          end
        end
      end
    end

  end
end
