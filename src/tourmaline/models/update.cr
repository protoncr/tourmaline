require "json"

module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  struct Update
    JSON.mapping(

      # The update‘s unique identifier. Update identifiers start from a certain
      # positive number and increase sequentially. This ID becomes especially
      # handy if you’re using Webhooks, since it allows you to ignore
      # repeated updates or to restore the correct update sequence,
      # should they get out of order. If there are no new updates
      # for at least a week, then identifier of the next update
      # will be chosen randomly instead of sequentially.
      update_id: Int64,

      # Optional. New incoming message of any kind — text, photo, sticker, etc.
      message: {type: Message, nilable: true},

      # Optional. New version of a message that is known to the bot and was edited
      edited_message: {type: Message, nilable: true},

      # Optional. New incoming channel post of any kind — text, photo, sticker, etc.
      channel_post: {type: Message, nilable: true},

      # Optional. New version of a channel post that is known to the bot and was edited
      edited_channel_post: {type: Message, nilable: true},

      # Optional. New incoming inline query
      inline_query: {type: InlineQuery, nilable: true},

      # Optional. The result of an inline query that was chosen by a user and sent to
      # their chat partner. Please see our documentation on the feedback collecting
      # for details on how to enable these updates for your bot.
      chosen_inline_result: {type: ChosenInlineResult, nilable: true},

      # Optional. New incoming callback query
      callback_query: {type: CallbackQuery, nilable: true},

      # Optional. New incoming shipping query. Only for invoices with flexible price
      shipping_query: {type: ShippingQuery, nilable: true},

      # Optional. New incoming pre-checkout query. Contains full information about checkout
      pre_checkout_query: {type: PreCheckoutQuery, nilable: true}
    )
  end
end
