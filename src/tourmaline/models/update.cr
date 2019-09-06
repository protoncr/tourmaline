require "json"

module Tourmaline::Model
  # # This object represents a Telegram user or bot.
  struct Update
    include JSON::Serializable

    # The update‘s unique identifier. Update identifiers start from a certain
    # positive number and increase sequentially. This ID becomes especially
    # handy if you’re using Webhooks, since it allows you to ignore
    # repeated updates or to restore the correct update sequence,
    # should they get out of order. If there are no new updates
    # for at least a week, then identifier of the next update
    # will be chosen randomly instead of sequentially.
    getter update_id : Int64

    # Optional. New incoming message of any kind — text, photo, sticker, etc.
    getter message : Message?

    # Optional. New version of a message that is known to the bot and was edited
    getter edited_message : Message?

    # Optional. New incoming channel post of any kind — text, photo, sticker, etc.
    getter channel_post : Message?

    # Optional. New version of a channel post that is known to the bot and was edited
    getter edited_channel_post : Message?

    # Optional. New incoming inline query
    getter inline_query : InlineQuery?

    # Optional. The result of an inline query that was chosen by a user and sent to
    # their chat partner. Please see our documentation on the feedback collecting
    # for details on how to enable these updates for your bot.
    getter chosen_inline_result : ChosenInlineResult?

    # Optional. New incoming callback query
    getter callback_query : CallbackQuery?

    # Optional. New incoming shipping query. Only for invoices with flexible price
    getter shipping_query : ShippingQuery?

    # Optional. New incoming pre-checkout query. Contains full information about checkout
    getter pre_checkout_query : PreCheckoutQuery?
  end
end
