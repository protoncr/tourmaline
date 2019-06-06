require "json"

module Tourmaline::Bot::Model
  class CallbackQuery
    JSON.mapping(

      id: String,

      from: User,

      message: Message?,

      inline_message_id: String?,

      chat_instance: String?,

      data: String?,

      game_short_name: String?
    )
  end
end
