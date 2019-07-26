require "../models"
require "./middleware_handler"

module Tourmaline::Bot
  # Allows your bot to hook into specific `UpdateAction`s.
  module EventHandler
    include MiddlewareHandler

    macro included
      @event_handlers = {} of String => Array(Model::Update ->)
    end

    # Preform an action when a specific `UpdateAction` is called.
    #
    # ```
    # bot.on(:new_chat_members) do |update|
    #   # persist the user to a database
    # end

    # bot.on(:left_chat_member) do |update|
    #   # remove chat member from database
    # end
    # ```
    def on(actions : UpdateAction | Array(UpdateAction), &block : Model::Update ->)
      actions = [actions] unless UpdateAction.is_a?(Array)
      actions.as(Array(UpdateAction)).each do |action|
        @event_handlers[action.to_s] ||= [] of Model::Update ->
        @event_handlers[action.to_s] << block
      end
    end

    # Triggers events when correct `UpdateAction`s are received.
    def handle_update(update) # ameba:disable Metrics/CyclomaticComplexity
      trigger_all_middlewares(update)

      if message = update.message
        trigger(UpdateAction::Message, update)

        if chat = message.chat
          trigger(UpdateAction::PinnedMessage, update) if chat.pinned_message
        end

        trigger(UpdateAction::Text, update) if message.text
        trigger(UpdateAction::Audio, update) if message.audio
        trigger(UpdateAction::Document, update) if message.document
        trigger(UpdateAction::Photo, update) if message.photo
        trigger(UpdateAction::Sticker, update) if message.sticker
        trigger(UpdateAction::Video, update) if message.video
        trigger(UpdateAction::Voice, update) if message.voice
        trigger(UpdateAction::Contact, update) if message.contact
        trigger(UpdateAction::Location, update) if message.location
        trigger(UpdateAction::Venue, update) if message.venue
        trigger(UpdateAction::NewChatMembers, update) if message.new_chat_members
        trigger(UpdateAction::LeftChatMember, update) if message.left_chat_member
        trigger(UpdateAction::NewChatTitle, update) if message.new_chat_title
        trigger(UpdateAction::NewChatPhoto, update) if message.new_chat_photo
        trigger(UpdateAction::DeleteChatPhoto, update) if message.delete_chat_photo
        trigger(UpdateAction::GroupChatCreated, update) if message.group_chat_created
        trigger(UpdateAction::MigrateToChatId, update) if message.migrate_from_chat_id
        trigger(UpdateAction::SupergroupChatCreated, update) if message.supergroup_chat_created
        trigger(UpdateAction::ChannelChatCreated, update) if message.channel_chat_created
        trigger(UpdateAction::MigrateFromChatId, update) if message.migrate_from_chat_id
        trigger(UpdateAction::Game, update) if message.game
        trigger(UpdateAction::VideoNote, update) if message.video_note
        trigger(UpdateAction::Invoice, update) if message.invoice
        trigger(UpdateAction::SuccessfulPayment, update) if message.successful_payment
      end

      trigger(UpdateAction::EditedMessage, update) if update.edited_message
      trigger(UpdateAction::ChannelPost, update) if update.channel_post
      trigger(UpdateAction::EditedChannelPost, update) if update.edited_channel_post
      trigger(UpdateAction::InlineQuery, update) if update.inline_query
      trigger(UpdateAction::ChosenInlineResult, update) if update.chosen_inline_result
      trigger(UpdateAction::CallbackQuery, update) if update.callback_query
      trigger(UpdateAction::ShippingQuery, update) if update.shipping_query
      trigger(UpdateAction::PreCheckoutQuery, update) if update.pre_checkout_query
    rescue ex
      logger.error("Update was not handled because: #{ex.message}")
    end

    # Triggers an update event.
    protected def trigger(event : UpdateAction, update : Model::Update)
      if @event_handlers.has_key?(event.to_s)
        procs = @event_handlers[event.to_s]
        procs.each do |proc|
          proc.call(update)
        end
      end
    end
  end
end
