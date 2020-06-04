module Tourmaline
  # Filters messages that include a specific command or commands.
  #
  # Options:
  # - `commands : String | Array(String)` - the command(s) to match (without the prefix)
  # - `prefix : String | Array(String)` - the prefix that should preceed the command(s); keep in mind that
  #    with group privacy mode enabled, only `/` will work as a prefix unless your bot is an admin
  # - `private_only : Bool` - if true, command(s) will only be available in private chats
  # - `group_only : Bool` - if true, command(s) will only be available in group chats
  # - `admin_only : Bool` if true, command(s) will only work for group admins
  #
  # Note: It's only recommended to use `admin_only` in smaller bots. It makes a call to `getChatAdministrators`
  # every time. For more popular bots it is recommended to implement your own admin caching.
  #
  # Context additions:
  # - `command : String` - the matched command
  # - `text : String` - the raw text without the command
  # - `botname : Bool?` - true if the bot name was included in the command
  #
  # Example:
  # ```crystal
  # filter = CommandFilter.new("echo")
  # ```
  class CommandFilter < Filter
    DEFAULT_PREFIXES = ["/"]

    property commands : Array(String)
    property prefixes : Array(String)
    property private_only : Bool
    property group_only : Bool
    property admin_only : Bool

    def initialize(commands : String | Array(String),
                   prefix = nil,
                   @private_only = false,
                   @group_only = false,
                   @admin_only = false)
      prefix ||= DEFAULT_PREFIXES
      @commands = commands.is_a?(Array) ? commands : [commands]
      @prefixes = prefix.is_a?(Array) ? prefix : [prefix]
    end

    def exec(client : Client, update : Update) : Bool
      if message = update.message
        if (text = message.text) || (text = message.caption)
          return false if private_only && message.chat.type != "private"
          return false if (group_only || admin_only) && message.chat.type == "private"

          if @admin_only
            if from = message.from
              admins = client.get_chat_administrators(message.chat.id)
              ids = admins.map(&.user.id)
              return false unless ids.includes?(from.id)
            end
          end

          tokens = text.split(/\s+/, 2)
          return false if tokens.empty?

          command = tokens[0]
          text = tokens[1]? || ""

          if command.includes?("@")
            command, botname = command.split("@", 2)
            return false unless botname == client.bot_name
          end

          prefix_re = /^#{@prefixes.join('|')}/

          return false unless command.match(prefix_re)
          command = command.sub(prefix_re, "")
          return false unless @commands.includes?(command)

          update.set_context({ command: command, text: text, botname: !!botname })
          return true
        end
      end
      false
    end
  end
end
