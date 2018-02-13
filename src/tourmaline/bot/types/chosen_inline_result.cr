require "json"

module Tourmaline::Bot

  class ChosenInlineResult

    JSON.mapping(
      result_id:         String,
      from:              User,
      location:          Location?,
      inline_message_id: String?,
      query:             String,
    )

  end

end
