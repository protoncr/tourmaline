module Tourmaline
  alias BotCommandScope = BotCommandScopeDefault | BotCommandScopeAllPrivateChats | BotCommandScopeAllGroupChats |
                          BotCommandScopeAllChatAdministrators | BotCommandScopeChat | BotCommandScopeChatAdministrators |
                          BotCommandScopeChatMember
end
