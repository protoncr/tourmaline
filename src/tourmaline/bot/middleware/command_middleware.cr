module Tourmaline::Bot
  # Used by `Client` to allow the handling of commands.
  # Commands are prefixed with `/`.
  class CommandMiddleware < Middleware
    # @bot : Tourmaline::Bot::Client - Inherited
    @commands = {} of String => Model::Message, Array(String) ->

    property :commands

    def call(update : Model::Update)
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
                if pieces[1] != @bot.bot_name
                  next
                end

                command_name = pieces[0]
              end

              # Check the command against the commands hash
              if @commands.has_key?(command_name)
                command = @commands[command_name]
                rest = message_text[entity.length..-1]
                params = rest.split(/\s+/, remove_empty: true)
                command.call(message, params)
              end
            end
          end
        end
      end
    end
  end
end
