module Tourmaline
  class BotCommandScopeChatMember
    include JSON::Serializable
    include Tourmaline::Model

    getter type : String = "chat_member"

    # Unique identifier for the target chat or username of the target supergroup
    # (in the format `@supergroupusername`)
    property chat_id : Int64 | String

    # Unique identifier of the target user
    property user_id : Int64

    def initialize(chat : Chat | Int64 | String, user : User | Int64)
      @chat_id = chat.is_a?(Chat) ? chat.id : chat
      @user_id = user.is_a?(User) ? user.id : user
    end
  end
end
