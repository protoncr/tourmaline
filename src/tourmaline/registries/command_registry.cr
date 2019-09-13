module Tourmaline
  module CommandRegistry
    getter commands = {} of String => Proc(Model::Message, Array(String), Nil)

    private def register_commands
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(Command) || method.annotation(Tourmaline::Command)) %}
              %prefix = {{ann[:prefix] || '/'}}
              %proc = ->(message : Model::Message, params : Array(String)){ {{method.name.id}}(message, params); nil }

              %command = {{ann[0]}}
              %command = %command.is_a?(Array) ? %command.map { |cmd| %prefix + cmd } : %prefix + %command

              command(%command, %proc)
            {% end %}
          {% end %}
        {% end %}

        on(:message, ->trigger_commands(Model::Update))

        @commands
      {% end %}
    end

    def command(names : String | Array(String), &block : Model::Message, Array(String) ->)
      command(names, block)
    end

    def command(names : String | Array(String), proc : Model::Message, Array(String) ->)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          commands[name] = proc
        end
      else
        names = names[1..-1] if names[0] == "/"
        commands[names] = proc
      end
    end

    private def trigger_commands(update : Model::Update)
      if message = update.message
        if message_text = message.text
          pieces = message_text.split(/\s/)

          command = pieces[0]

          # Check if the command has the bot's name attached
          if command.includes?("@")
            cmd_pieces = command.split("@")
            if cmd_pieces[1] != bot_name
              return
            end

            command = cmd_pieces[0]
          end

          params = pieces[1..-1]

          # Check the command against the commands hash
          if @commands.has_key?(command)
            proc = @commands[command]
            spawn proc.call(message, params)
          end
        end
      end

      nil
    end
  end
end
