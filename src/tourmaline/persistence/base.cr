module Tourmaline
  module Persistence
    abstract class Base
      abstract def save_user(user : User) : User

      abstract def save_chat(chat : Chat) : Chat

      abstract def save_chat_member(chat_id, chat_member : ChatMember) : ChatMember

      abstract def update_user(user : User) : User

      abstract def update_chat(chat : Chat) : Chat

      abstract def update_chat_member(chat_id, chat_member : ChatMember) : ChatMember

      abstract def user_exists?(user_id) : Bool

      abstract def chat_exists?(chat_id) : Bool

      abstract def chat_member_exists?(chat_id, user_id) : Bool

      abstract def get_user(user_id) : User

      abstract def get_chat(chat_id) : Chat

      abstract def get_chat_member(chat_id, user_id) : ChatMember
    end
  end
end
