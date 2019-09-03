module Tourmaline
  module CommandRegistry
    alias CommandSig = NamedTuple(proc: Proc(Model::Message, Array(String), Nil), at_start: Bool)
    getter commands = {} of String => CommandSig

    private def register_commands
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(Command) || method.annotation(Tourmaline::Command)) %}
              %at_start = {{!!ann[:at_start]}}
              %proc = ->(message : Model::Message, params : Array(String)){ {{method.name.id}}(message, params); nil }
              command({{ann[0]}}, at_start: %at_start, proc: %proc)
            {% end %}
          {% end %}
        {% end %}

        on(:message, ->trigger_commands(Model::Update))

        @commands
      {% end %}
    end

    def command(names : String | Array(String), at_start = true, &block : Model::Message, Array(String) ->)
      command(names, block, at_start)
    end

    def command(names : String | Array(String), proc : Model::Message, Array(String) ->, at_start = true)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          commands[name] = {proc: proc, at_start: at_start}
        end
      else
        names = names[1..-1] if names[0] == "/"
        commands[names] = {proc: proc, at_start: at_start}
      end
    end

    private def trigger_commands(update : Model::Update)
      if (message = update.message) && (entities = message.entities)
        entities.each do |entity|
          if entity.type == "bot_command"
            message_text = message.text.not_nil!

            # Get the command value
            command_name = message_text[(entity.offset + 1)..(entity.length + entity.offset - 1)]
            message_text = message_text[entity.offset..-1]

            # Check if the command has the bot's name attached
            if command_name.includes?("@")
              pieces = command_name.split("@")
              if pieces[1] != bot_name
                next
              end

              command_name = pieces[0]
            end

            # Check the command against the commands hash
            if command = @commands[command_name]?
              next unless entity.offset == 0 || command[:at_start] == false
              rest = message_text[entity.length..-1]
              params = rest.split(/\s+/, remove_empty: true)
              command[:proc].call(message, params)
            end
          end
        end
      end
    end
  end
end
