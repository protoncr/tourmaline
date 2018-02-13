require "../types"

module Tourmaline::Bot
  module EventHandler

    macro included
      @event_handlers = {} of String => Update ->
    end

    def on(actions : UpdateAction | Array(UpdateAction), &block : Update ->)
      actions = [ actions ] unless UpdateAction.is_a?(Array)
      actions.as(Array(UpdateAction)).each do |action|
        @event_handlers[action.to_s] = block
      end
    end

    def handle_update(update)
      trigger_all_middlewares(update)

      case update
      when .message
        trigger(UpdateAction::Message, update)
      when .edited_message
        trigger(UpdateAction::EditedMessage, update)
      when .channel_post
        trigger(UpdateAction::ChannelPost, update)
      when .edited_channel_post
        trigger(UpdateAction::EditedChannelPost, update)
      when .inline_query
        trigger(UpdateAction::InlineQuery, update)
      when .chosen_inline_result
        trigger(UpdateAction::ChosenInlineResult, update)
      when .callback_query
        trigger(UpdateAction::CallbackQuery, update)
      when .shipping_query
        trigger(UpdateAction::ShippingQuery, update)
      when .pre_checkout_query
        trigger(UpdateAction::PreCheckoutQuery, update)
      end
    rescue ex
      logger.error("Update was not handled because: #{ex.message}")
    end

    def trigger(event : UpdateAction, update : Update)
      if @event_handlers.has_key?(event.to_s)
        proc = @event_handlers[event.to_s]
        proc.call(update)
      end
    end

  end
end
