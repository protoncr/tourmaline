module Tourmaline
  class CommandHandler < EventHandler
    getter actions : Array(UpdateAction) = [UpdateAction::Message]

    getter commands : Array(String)

    def initialize(commands : String | Array(String), @proc : EventHandlerProc)
      super()
      @commands = commands.is_a?(String) ? [commands] : commands
    end

    def self.new(commands : String | Array(String), &block : EventHandlerProc)
      new(commands, block)
    end

    def call(ctx : Context)
      if (message = ctx.message) || (message = ctx.channel_post)
        if (text = message.text) || (text = message.caption)
          command_entities = message.text_entities("bot_command").to_a
          return if command_entities.empty?

          _, command = command_entities.first
          command = command[1..]
          command = command.includes?("@") ? command.split("@").first : command
          return unless @commands.includes?(command)

          @proc.call(ctx)
        end
      end
    end
  end
end
