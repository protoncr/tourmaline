# require "db"

# module Tourmaline
#   # Stores all persisted data in a database. The database you use is up to you,
#   # just make sure to reuqire the appropriate adapter.
#   #
#   # A `DB::Database` instance should be passed to the initializer.
#   class DBPersistence < Persistence
#     getter db : DB::Database
#     property users_table : String
#     property chats_table : String

#     def initialize(@db : DB::Database,
#                    @users_table : String = "users",
#                    @chats_table : String = "chats")
#     end

#     def update_user(user : User) : User
#       query = <<-SQL
#         REPLACE INTO #{@users_table} (
#           id, is_bot, first_name, last_name, username, language_code,
#           can_join_groups, can_read_all_group_messages, supports_inline_queries
#         ) values (?, ?, ?, ?, ?, ?, ?, ?, ?)
#       SQL
#       @db.exec(query, user.id, user.is_bot, user.first_name, user.last_name, user.username, user.language_code,
#         user.can_join_groups, user.can_read_all_group_messages, user.supports_inline_queries)
#       user
#     end

#     def update_chat(chat : Chat) : Chat
#       query = <<-SQL
#         REPLACE INTO #{@chats_table} (
#           id, type, title, username, first_name, last_name, description,
#           invite_link, slow_mode_delay, sticker_set_name, can_set_sticker_set
#         ) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
#       SQL
#       @db.exec(query, chat.id, chat.type, chat.title, chat.username, chat.first_name, chat.last_name,
#         chat.description, nil, chat.slow_mode_delay, chat.sticker_set_name, chat.can_set_sticker_set)
#       chat
#     end

#     def user_exists?(user_id : Int) : Bool
#       @db.scalar("SELECT COUNT(*) from #{@users_table} WHERE id=?", user_id) > 0
#     end

#     def user_exists?(username : String) : Bool
#       @db.scalar("SELECT COUNT(*) from #{@users_table} WHERE username=?", username) > 0
#     end

#     def chat_exists?(chat_id : Int) : Bool
#       @db.scalar("SELECT COUNT(*) from #{@chats_table} WHERE id=?", chat_id) > 0
#     end

#     def chat_exists?(username : String) : Bool
#       @db.scalar("SELECT COUNT(*) from #{@chats_table} WHERE username=?", username) > 0
#     end

#     def get_user(user_id : Int) : User?
#       query = "SELECT * FROM #{@users_table} WHERE id=?"
#       rs = @db.query(query, user_id)
#       User.from_rs(rs)[0]?
#     rescue
#     end

#     def get_user(username : String) : User?
#       query = "SELECT * FROM #{@users_table} WHERE username=?"
#       rs = @db.query(query, username)
#       User.from_rs(rs)[0]?
#     rescue
#     end

#     def get_chat(chat_id : Int) : Chat?
#       query = "SELECT * FROM #{@chats_table} WHERE id=?"
#       rs = @db.query(query, chat_id)
#       Chat.from_rs(rs)[0]?
#     rescue
#     end

#     def get_chat(username : String) : Chat?
#       query = "SELECT * FROM #{@chats_table} WHERE username=?"
#       rs = @db.query(query, username)
#       Chat.from_rs(rs)[0]?
#     rescue
#     end

#     def init
#       users_query = <<-SQL
#         CREATE TABLE IF NOT EXISTS #{@users_table} (
#           id INT(16) NOT NULL PRIMARY KEY,
#           is_bot BOOLEAN DEFAULT FALSE,
#           first_name VARCHAR(255) NOT NULL,
#           last_name VARCHAR(255),
#           username VARCHAR(32),
#           language_code VARCHAR(8),
#           can_join_groups BOOLEAN DEFAULT FALSE,
#           can_read_all_group_messages BOOLEAN DEFAULT FALSE,
#           supports_inline_queries BOOLEAN DEFAULT FALSE
#         )
#       SQL

#       chats_query = <<-SQL
#         CREATE TABLE IF NOT EXISTS #{@chats_table} (
#           id INT(32) NOT NULL PRIMARY KEY,
#           type VARCHAR(255),
#           title VARCHAR(255),
#           username VARCHAR(32),
#           first_name VARCHAR(255) NOT NULL,
#           last_name VARCHAR(255),
#           description VARCHAR(255),
#           invite_link VARCHAR(255),
#           slow_mode_delay INT(32),
#           sticker_set_name VARCHAR(255),
#           can_set_sticker_set BOOLEAN DEFAULT FALSE
#         )
#       SQL

#       @db.exec(users_query)
#       @db.exec(chats_query)
#     end

#     def handle_update(update : Update)
#       update.users.each &->update_user(User)
#       update.chats.each &->update_chat(Chat)
#     end

#     def cleanup
#       @db.close
#     end
#   end
# end
