module Tourmaline
  # Define a new Command. By default all commands start with a `/` and
  # commands are accessable to all chat types. You can change these
  # defaults by supplying named parameters to the annotation.
  #
  # Options:
  # - `commands` - the command(s) to use. should be a prefixless string or symbol.
  # - `prefix` - the prefix for this command. defaults to `/`.
  # - `remove_leading` - if true the `text` value passed to the command context will not include the command, if the command is at the beginning. defaults to `true`.
  # - `private_only` - if true this command will only be allowed inside of private chats.
  # - `group_only` - if true this command will only be allowed inside of groups.
  #
  # Example:
  #
  # ```crystal
  # @[Command("help", prefix: "!", private_only: true)]
  # def help_command(client, update)
  #   update.message.not_nil!.reply("This is a help message")
  # end
  # ```
  annotation Command; end

  class CommandHandler < EventHandler
    DEFAULT_PREFIXES = ["/"]

    property commands : Array(String)
    property prefixes : Array(String)
    property private_only : Bool
    property group_only : Bool
    property admin_only : Bool

    def initialize(commands,
                   prefix = nil,
                   group = :default,
                   async = true,
                   @private_only = false,
                   @group_only = false,
                   @admin_only = false,
                   &block : Context ->)
      super(group, async)
      prefix ||= DEFAULT_PREFIXES

      commands = commands.is_a?(Array) ? commands : [commands]
      @commands = commands.map(&.to_s)

      @prefixes = prefix.is_a?(Array) ? prefix : [prefix]
      @proc = block
    end

    def call(client : Client, update : Update)
      if message = update.message
        if (text = message.text) || (text = message.caption)
          return if private_only && message.chat.type != "private"
          return if (group_only || admin_only) && message.chat.type == "private"

          if @admin_only
            if from = message.from
              admins = client.get_chat_administrators(message.chat.id)
              ids = admins.map(&.user.id)
              return unless ids.includes?(from.id)
            end
          end

          tokens = text.split(/\s+/, 2)
          return if tokens.empty?

          command = tokens[0]
          text = tokens[1]? || ""

          if command.includes?("@")
            command, botname = command.split("@", 2)
            return unless botname == client.bot.username.to_s
          end

          prefix_re = /^#{@prefixes.join('|')}/

          return unless command.match(prefix_re)
          command = command.sub(prefix_re, "")
          return unless @commands.includes?(command)

          context = Context.new(update, message, command, text, !!botname)
          @proc.call(context)
          return true
        end
      end
    end

    def self.annotate(client)
      {% begin %}
        {% for command_class in Tourmaline::Client.subclasses %}
          {% for method in command_class.methods %}

            # Handle `Command` annotation
            {% for ann in method.annotations(Command) %}
              %command = {{ ann.named_args[:command] || ann.named_args[:commands] || ann.args[0] }}
              %prefix = {{ ann.named_args[:prefix] }}
              %group  = {{ ann.named_args[:group] || :default }}
              %async = {{ !!ann[:async] }}
              %private_only = {{ ann.named_args[:private_only] || false }}
              %group_only = {{ ann.named_args[:group_only] || false }}
              %admin_only = {{ ann.named_args[:admin_only] || false }}

              %handler = CommandHandler.new(
                %command,
                %prefix,
                %group,
                %async,
                %private_only,
                %group_only,
                %admin_only,
                &->(ctx : Context) { client.{{ method.name.id }}(ctx) }
              )

              client.add_event_handler(%handler)
            {% end %}
          {% end %}
        {% end %}
      {% end %}
    end

    record Context, update : Update, message : Message, command : String, text : String, botname : Bool do
      def botname?
        @botname
      end
    end
  end
end
