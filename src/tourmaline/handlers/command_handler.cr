module Tourmaline
  module Handlers
    class CommandHandler < EventHandler
      DEFAULT_PREFIXES = ["/"]

      # Commands (without prefix) that this handler should respond to.
      property commands : Array(String)

      # Prefixes that commands should start with.
      property prefixes : Array(String)

      # If true, this handler will only respond if the command is sent in private.
      property private_only : Bool

      # If true, this handler will only respond if the command is sent in a group.
      property group_only : Bool

      # If true, this handler will only respond if the command is sent by a group admin.
      property admin_only : Bool

      # If true, this handler will also run (or re-run) when messages are edited.
      property on_edit : Bool

      # Create a new `CommandHandler` instance using the provided `commands`. `commands` can
      # be a single command string, or an array of possible commands.
      #
      # !!! warning
      #     If `#admin_only` is true, `get_chat_adminstrators` will be run every time the
      #     handler is invoked. This should be fine in testing, but in production it's
      #     recommended to cache admins and do your own guarding.
      def initialize(commands,
                    prefix = nil,
                    group = :default,
                    priority = 0,
                    @private_only = false,
                    @group_only = false,
                    @admin_only = false,
                    @on_edit = false,
                    &block : Context ->)
        super(group, priority)
        prefix ||= DEFAULT_PREFIXES

        commands = commands.is_a?(Array) ? commands : [commands]
        @commands = commands.map(&.to_s)

        @prefixes = prefix.is_a?(Array) ? prefix : [prefix]
        @proc = block
      end

      def call(client : Client, update : Update)
        if (message = update.message || update.channel_post) || (@on_edit && (message = update.edited_message || update.edited_channel_post))
          if ((raw_text = message.raw_text) && (text = message.text)) ||
              (raw_text = message.raw_caption && (text = message.caption))
            return if private_only && message.chat.type != Chat::Type::Private
            return if (group_only || admin_only) && message.chat.type == Chat::Type::Private

            if @admin_only
              if from = message.from
                admins = client.get_chat_administrators(message.chat.id)
                ids = admins.map(&.user.id)
                return unless ids.includes?(from.id)
              end
            end

            text = text.to_s
            raw_text = raw_text.to_s

            tokens = text.split(/\s+/)
            tokens = tokens.size > 1 ? text.split(/\s+/, 2) : [tokens[0], ""]

            raw_tokens = raw_text.split(/\s+/)
            return if tokens.empty?

            command = raw_tokens[0]
            text = tokens[1]

            if command.includes?("@")
              command, botname = command.split("@", 2)
              return unless botname.downcase == client.bot.username.to_s.downcase
            end

            prefix_re = /^#{@prefixes.join('|')}/

            return unless command.match(prefix_re)
            command = command.sub(prefix_re, "")
            return unless @commands.includes?(command)

            context = Context.new(update, message, command, text, raw_text, !!botname, !!update.edited_message)
            @proc.call(context)
            return true
          end
        end
      end

      # :nodoc:
      def self.annotate(client)
        {% begin %}
          {% for command_class in Tourmaline::Client.subclasses %}
            {% for method in command_class.methods %}

              # Handle `Command` annotation
              {% for ann in method.annotations(Command) %}
                %command = {{ ann.named_args[:command] || ann.named_args[:commands] || ann.args[0] }}
                %prefix = {{ ann.named_args[:prefix] }}
                %group  = {{ ann.named_args[:group] || :default }}
                %priority = {{ ann[:priority] || 0 }}
                %private_only = {{ ann.named_args[:private_only] || false }}
                %group_only = {{ ann.named_args[:group_only] || false }}
                %admin_only = {{ ann.named_args[:admin_only] || false }}
                %on_edit = {{ ann.named_args[:on_edit] || false }}

                %handler = CommandHandler.new(
                  %command,
                  %prefix,
                  %group,
                  %priority,
                  %private_only,
                  %group_only,
                  %admin_only,
                  %on_edit,
                  &->(ctx : Context) { client.{{ method.name.id }}(ctx); nil }
                )

                client.add_event_handler(%handler)
              {% end %}
            {% end %}
          {% end %}
        {% end %}
      end

      record Context, update : Update, message : Message, command : String, text : String, raw_text : String, botname : Bool, edit : Bool
    end
  end
end
