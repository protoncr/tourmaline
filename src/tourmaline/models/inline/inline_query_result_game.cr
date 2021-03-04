module Tourmaline
  class InlineQueryResultGame < InlineQueryResult
    getter type : String = "game"

    getter id : String

    getter game_short_name : String

    getter reply_markup : InlineKeyboardMarkup?

    def initialize(@id : String, @game_short_name, @reply_markup = nil)
    end
  end
end
