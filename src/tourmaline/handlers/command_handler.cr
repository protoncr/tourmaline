module Tourmaline
  module Handlers
    class CommandHandler < EventHandler
      ANNOTATION = Command

      # Commands (without prefix) that this handler should respond to.
      property commands : Array(String)

      # Prefixes that commands should start with.
      property prefixes : Array(String)

      # User API: if true, this command will only be activated by an outgoing message.
      property outgoing : Bool

      # If true, this handler will only respond if the command is sent in private.
      property private_only : Bool

      # If true, this handler will only respond if the command is sent in a group.
      property group_only : Bool

      # If true, this handler will also run (or re-run) when messages are edited.
      property on_edit : Bool

      # Register this command with BotFather. Only works is `prefixes` contains `/` (as
      # it does by default), as non-botcommands can't be registed with BotFather.
      property register : Bool

      # By default the first command in `commands` will be selected as the command name
      # to register. If this property is set, it will be used instead.
      property register_as : String?

      # Used when registering the command with BotFather. If `register` is true, but this
      # is not set, the command will not be registered.
      property description : String?

      # Create a new `CommandHandler` instance using the provided `commands`. `commands` can
      # be a single command string, or an array of possible commands.
      #
      # !!! warning
      #     If `#admin_only` is true, `get_chat_adminstrators` will be run every time the
      #     handler is invoked. This should be fine in testing, but in production it's
      #     recommended to cache admins and do your own guarding.
      def initialize(commands,
                     prefix = nil,
                     @outgoing = true,
                     @private_only = false,
                     @group_only = false,
                     @on_edit = false,
                     @register = false,
                     @register_as = nil,
                     @description = nil,
                     &block : Context ->)
        super()

        if prefix
          @prefixes = prefix.is_a?(Array) ? prefix : [prefix]
        else
          @prefixes = Tourmaline::Client.default_command_prefixes
        end

        commands = commands.is_a?(Array) ? commands : [commands]
        @commands = commands.map(&.to_s)
        @proc = block
      end

      def call(update : Update)
        if (message = update.message || update.channel_post) || (@on_edit && (message = update.edited_message || update.edited_channel_post))
          return if message.outgoing? unless @outgoing
          if ((raw_text = message.raw_text) && (text = message.text)) ||
             (raw_text = message.raw_caption && (text = message.caption))
            return if private_only && message.chat.private?
            return if group_only && message.chat.private?

            text = text.to_s
            raw_text = raw_text.to_s

            tokens = text.split(/\s+/)
            tokens = tokens.size > 1 ? text.split(/\s+/, 2) : [tokens[0], ""]

            raw_tokens = raw_text.split(/\s+/)
            return if tokens.empty?

            command = raw_tokens[0]
            text = tokens[1]

            if command.starts_with?('/') && command.includes?("@")
              command, botname = command.split("@", 2)
              return unless botname.downcase == client.bot.username.to_s.downcase
            end

            prefix_re = /^#{@prefixes.map(&->Regex.escape(String)).join('|')}/

            return unless command.match(prefix_re)
            command = command.sub(prefix_re, "")
            return unless @commands.includes?(command)

            context = Context.new(update, update.context, message, command, text, raw_text, !!botname, !!update.edited_message)
            @proc.call(context)
            return true
          end
        end
      end

      record Context,
        update : Update,
        context : Middleware::Context,
        message : Message,
        command : String,
        text : String,
        raw_text : String,
        botname : Bool,
        edit : Bool
    end
  end
end
