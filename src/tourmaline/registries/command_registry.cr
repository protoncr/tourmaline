module Tourmaline
  module CommandRegistry
    record CommandWrapper, name : String, prefix : String, private_only : Bool, proc : Proc(Tourmaline::Context, Nil)
    getter commands = [] of CommandWrapper

    private def register_commands
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(Command) || method.annotation(Tourmaline::Command)) %}
              %command = {{ann[0] || ann[:command]}}
              %prefix = {{ann[:prefix] || "/"}}
              %private_only = {{ann[:private_only] || false}}
              %proc = ->(ctx : Tourmaline::Context){ {{method.name.id}}(ctx); nil }

              command(%command, %proc, %prefix, %private_only)
            {% end %}
          {% end %}
        {% end %}

        on(:message, ->trigger_commands(Model::Update))

        @commands
      {% end %}
    end

    def command(names : String | Array(String), prefix = "/", private_only = false, &block : Tourmaline::Context ->)
      command(names, block)
    end

    def command(names : String | Array(String), proc : Tourmaline::Context ->, prefix = "/", private_only = false)
      if names.is_a?(Array)
        names.each { |name| command(name, proc, prefix, private_only) }
      else
        command = CommandWrapper.new(names, prefix, private_only, proc)
        commands << command
      end
    end

    private def trigger_commands(update : Model::Update)
      if message = update.message
        if message_text = message.text
          return unless message_text.size >= 2

          command = message_text.split(" ")[0]
          text    = message_text.sub(command, "").lstrip

          # Check if the command has the bot's name attached
          if command.includes?("@")
            command, name = command.split("@")
            if name != bot_name
              return
            end
          end

          # Check the command against the commands hash
          @commands.each do |cmd|
            if cmd.name == command[1..-1] && cmd.prefix == command[0].to_s
              return if cmd.private_only && !(message.chat.type == "private")
              context = Tourmaline::Context.new(self, update, message, command[1..-1], text)
              spawn cmd.proc.call(context)
            end
          end
        end
      end

      nil
    end
  end
end
