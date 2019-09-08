module Tourmaline
  module Persistence
    abstract class Base
      abstract def save_user(user : Model::User) : Model::User

      abstract def save_chat(chat : Model::Chat) : Model::Chat

      abstract def save_chat_member(chat_id, chat_member : Model::ChatMember) : Model::ChatMember

      abstract def update_user(user : Model::User) : Model::User

      abstract def update_chat(chat : Model::Chat) : Model::Chat

      abstract def update_chat_member(chat_id, chat_member : Model::ChatMember) : Model::ChatMember

      abstract def user_exists?(user_id) : Bool

      abstract def chat_exists?(chat_id) : Bool

      abstract def chat_member_exists?(chat_id, user_id) : Bool

      abstract def get_user(user_id) : Model::User

      abstract def get_chat(chat_id) : Model::Chat

      abstract def get_chat_member(chat_id, user_id) : Model::ChatMember
    end
  end
end
