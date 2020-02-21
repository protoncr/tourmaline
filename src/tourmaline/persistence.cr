module Tourmaline
  module Persistence
    abstract def insert_user(user : User) : User

    abstract def update_chat(chat : Chat) : Chat

    abstract def update_user(user : User) : User

    abstract def update_chat(chat : Chat) : Chat

    abstract def user_exists?(user_id) : Bool

    abstract def chat_exists?(chat_id : Int) : Bool

    abstract def get_user(user_id : Int) : User?

    abstract def get_chat(chat_id : Int) : Chat?

    abstract def handle_persistent_update(update : Update)

    abstract def init_p
    abstract def cleanup_p

    def get_users_from_update(update : Update)
      users = [] of User?

      {% for msg in %w(message edited_message channel_post edited_channel_post) %}
        if msg = update.{{msg.id}}
          users << msg.from
          users << msg.forward_from
          users << msg.left_chat_member

          users.concat msg.new_chat_members
        end
      {% end %}

      {% for query in %w(inline_query chosen_inline_result callback_query shipping_query pre_checkout_query) %}
        if query = update.{{query.id}}
          users << query.from
        end
      {% end %}

      if poll_answer = update.poll_answer
        users << poll_answer.user
      end

      users.compact
    end

    def get_chats_from_update(update : Update)
      chats = [] of Chat?

      {% for msg in %w(message edited_message channel_post edited_channel_post) %}
        if msg = update.{{msg.id}}
          chats << msg.chat
          chats << msg.forward_from_chat
        end
      {% end %}

      chats.compact
    end
  end
end
