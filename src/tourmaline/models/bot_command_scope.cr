module Tourmaline::Model
  alias BotCommandScope = BotCommandScopeDefault | BotCommandScopeAllPrivateChats | BotCommandScopeAllGroupChats |
                          BotCommandScopeAllChatAdministrators | BotCommandScopeChat | BotCommandScopeChatAdministrators |
                          BotCommandScopeChatMember
end
