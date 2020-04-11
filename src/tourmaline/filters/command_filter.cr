module Tourmaline
  # Filters messages that include a specific command or commands.
  #
  # Options:
  # - `commands : String | Array(String)` - the command(s) to match (without the prefix)
  # - `prefix : String` - the prefix that should preceed the command(s)
  # - `private_only : Bool` - if true, command(s) will only be available in private chats
  # - `group_only : Bool` - if true, command(s) will only be available in group chats
  # - `admin_only : Bool` if true, command(s) will only work for group admins
  #
  # Context additions:
  # - `command : String` - the matched command
  # - `text : String` - the raw text without the command
  #
  # Example:
  # ```crystal
  # filter = CommandFilter.new("echo")
  # ```
  class CommandFilter < Filter
    property commands : Array(String)
    property prefix : String
    property private_only : Bool
    property group_only : Bool
    property admin_only : Bool

    def initialize(commands : String | Array(String),
                   prefix = nil,
                   private_only = false,
                   group_only = false,
                   admin_only = false)
      @commands = commands.is_a?(Array) ? commands : [commands]
      @prefix = prefix || "/"
      @private_only = private_only
      @group_only = group_only
      @admin_only = admin_only
    end

    def exec(client : Client, update : Update) : Bool
      if message = update.message
        if (text = message.text) || (text = message.caption)
          return false if private_only && message.chat.type != "private"
          return false if group_only && message.chat == "private"

          # TODO: Cache admins so we don't have to call `get_chat_administrators` every time
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

          return false unless command.starts_with?(@prefix)
          command = command.sub(/^#{@prefix}/, "")
          return false unless @commands.includes?(command)

          update.set_context({ command: command, text: text })
          return true
        end
      end
      false
    end
  end
end
