module Tourmaline
  class CommandHandler < Handler
    ANNOTATIONS = [ Command ]

    getter commands : Array(String)
    getter proc : Proc(CommandContext, Void)
    getter prefix : String
    getter anywhere : Bool
    getter remove_leading : Bool

    def initialize(
      commands : String | Array(String),
      proc : CommandContext ->,
      @prefix : String = "/",
      @anywhere : Bool = false,
      @private_only : Bool = false,
      @remove_leading : Bool = true
    )
      @commands = commands.is_a?(Array) ? commands : [commands]
      @proc = ->(ctx : CommandContext) { proc.call(ctx); nil }
      validate_commands(@commands)
    end

    def actions : Array(UpdateAction)
      [ UpdateAction::Message ]
    end

    def call(client : Client, update : Update)
      if message = update.message
        if message_text = message.text
          return unless message_text.size >= 2

          if command = command_match(client, message)
            if @remove_leading
              re = Regex.new("^" + Regex.escape(@prefix + command) + "\\s+")
              message_text = message_text.sub(re, "")
            end

            return if @private_only && !(message.chat.type == "private")
            context = CommandContext.new(client, update, message, command, message_text)
            @proc.call(context)
          end
        end
      end
    end

    def check_update(client : Client, update : Update) : Bool
      true
    end

    private def validate_commands(commands)
      commands.each do |command|
        if command.match(/\s/)
          raise InvalidCommandError.new(command)
        end
      end
    end

    private def command_match(client : Client, message : Message)
      if text = message.text
        tokens = text.split(/\s+/)

        if !@anywhere && !tokens.empty?
          tokens = [tokens.first]
        end

        tokens.each do |token|
          if token.starts_with?(@prefix)
            token = token[@prefix.size..-1]
            if token.includes?("@")
              parts = token.split("@")
              if parts[0].in?(@commands) && parts[1]?
                if parts[1] == client.bot_name
                  return parts[0]
                end
              end
            elsif token.in?(@commands)
              return token
            end
          end
        end
      end
    end

    class InvalidCommandError < Exception
      def initialize(command)
        super("Invalid command format for command '#{command}'")
      end
    end
  end

  # `CommandContext` represents the data passed into a bot command. It gives access to
  # the `client`, the full `update`, the `message`, the `command`
  # (including the prefix), and the raw message `text`
  # (not including the command).
  #
  # Since it can be annoying and verbose to have to type `ctx.message.method`
  # every time, `CommandContext` also forwards missing methods to the message,
  # update, and client in that order. So rather than calling
  # `ctx.message.reply` you can just do `ctx.reply`.
  record CommandContext, client : Tourmaline::Client, update : Tourmaline::Update,
    message : Tourmaline::Message, command : String, text : String do
    macro method_missing(call)
      {% if Tourmaline::Message.has_method?(call.name) %}
        message.{{call}}
      {% elsif Tourmaline::Update.has_method?(call.name) %}
        update.{{call}}
      {% elsif Tourmaline::Client.has_method?(call.name) %}
        client.{{call}}
      {% else %}
        {% raise "Unexpected method '##{call.name}' for class #{@type.id}" %}
      {% end %}
    end
  end
end
