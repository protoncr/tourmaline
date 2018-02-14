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
        case update.message.not_nil!
        when .chat
          case update.message.not_nil!.chat
          when .pinned_message
            trigger(UpdateAction::PinnedMessage, update)
          end
        when .text
          trigger(UpdateAction::Text, update)
        when .audio
          trigger(UpdateAction::Audio, update)
        when .document
          trigger(UpdateAction::Document, update)
        when .photo
          trigger(UpdateAction::Photo, update)
        when .sticker
          trigger(UpdateAction::Sticker, update)
        when .video
          trigger(UpdateAction::Video, update)
        when .voice
          trigger(UpdateAction::Voice, update)
        when .contact
          trigger(UpdateAction::Contact, update)
        when .location
          trigger(UpdateAction::Location, update)
        when .venue
          trigger(UpdateAction::Venue, update)
        when .new_chat_members
          trigger(UpdateAction::NewChatMembers, update)
        when .left_chat_member
          trigger(UpdateAction::LeftChatMember, update)
        when .new_chat_title
          trigger(UpdateAction::NewChatTitle, update)
        when .new_chat_photo
          trigger(UpdateAction::NewChatPhoto, update)
        when .delete_chat_photo
          trigger(UpdateAction::DeleteChatPhoto, update)
        when .group_chat_created
          trigger(UpdateAction::GroupChatCreated, update)
        when .migrate_to_chat_id
          trigger(UpdateAction::MigrateToChatId, update)
        when .supergroup_chat_created
          trigger(UpdateAction::SupergroupChatCreated, update)
        when .channel_chat_created
          trigger(UpdateAction::ChannelChatCreated, update)
        when .migrate_from_chat_id
          trigger(UpdateAction::MigrateFromChatId, update)
        when .game
          trigger(UpdateAction::Game, update)
        when .video_note
          trigger(UpdateAction::VideoNote, update)
        when .invoice
          trigger(UpdateAction::Invoice, update)
        when .successful_payment
          trigger(UpdateAction::SuccessfulPayment, update)
        end
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
