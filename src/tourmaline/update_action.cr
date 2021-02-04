module Tourmaline
  # The available event types for `EventHandler`.
  enum UpdateAction
    Update
    Message
    ReplyMessage
    EditedMessage
    CallbackQuery
    InlineQuery
    ShippingQuery
    PreCheckoutQuery
    ChosenInlineResult
    ChannelPost
    EditedChannelPost

    Text
    Caption
    Audio
    Document
    Photo
    Sticker
    Video
    Voice
    Contact
    Location
    Venue
    NewChatMembers
    LeftChatMember
    NewChatTitle
    NewChatPhoto
    DeleteChatPhoto
    GroupChatCreated
    MigrateToChatId
    SupergroupChatCreated
    ChannelChatCreated
    MigrateFromChatId
    PinnedMessage
    Game
    VideoNote
    Invoice
    SuccessfulPayment
    ConnectedWebsite
    PassportData
    Poll
    PollAnswer
    ViaBot

    # 🎲
    Dice
    # 🎯
    Dart
    # 🏀
    Basketball
    # ⚽️
    Football
    # ⚽️ but American
    Soccerball
    # 🎰
    SlotMachine

    def to_s
      super.to_s.underscore
    end

    def self.to_a
      {{ @type.constants.map { |c| c.stringify.id } }}
    end

    # Takes an `Update` and returns an array of update actions.
    def self.from_update(update : Tourmaline::Update)
      actions = [] of UpdateAction

      actions << UpdateAction::Update

      if message = update.message
        actions << UpdateAction::Message
        actions << UpdateAction::ReplyMessage if message.reply_message

        if chat = message.chat
          actions << UpdateAction::PinnedMessage if chat.pinned_message
        end

        actions << UpdateAction::Text if message.text
        actions << UpdateAction::Caption if message.caption
        actions << UpdateAction::Audio if message.audio
        actions << UpdateAction::Document if message.document
        actions << UpdateAction::Photo if message.photo.size > 0
        actions << UpdateAction::Sticker if message.sticker
        actions << UpdateAction::Video if message.video
        actions << UpdateAction::Voice if message.voice
        actions << UpdateAction::Contact if message.contact
        actions << UpdateAction::Location if message.location
        actions << UpdateAction::Venue if message.venue
        actions << UpdateAction::NewChatMembers if message.new_chat_members.size > 0
        actions << UpdateAction::LeftChatMember if message.left_chat_member
        actions << UpdateAction::NewChatTitle if message.new_chat_title
        actions << UpdateAction::NewChatPhoto if message.new_chat_photo.size > 0
        actions << UpdateAction::DeleteChatPhoto if message.delete_chat_photo
        actions << UpdateAction::GroupChatCreated if message.group_chat_created
        actions << UpdateAction::MigrateToChatId if message.migrate_from_chat_id
        actions << UpdateAction::SupergroupChatCreated if message.supergroup_chat_created
        actions << UpdateAction::ChannelChatCreated if message.channel_chat_created
        actions << UpdateAction::MigrateFromChatId if message.migrate_from_chat_id
        actions << UpdateAction::Game if message.game
        actions << UpdateAction::VideoNote if message.video_note
        actions << UpdateAction::Invoice if message.invoice
        actions << UpdateAction::SuccessfulPayment if message.successful_payment
        actions << UpdateAction::ConnectedWebsite if message.connected_website
        actions << UpdateAction::PassportData if message.passport_data
        actions << UpdateAction::Poll if message.poll
        actions << UpdateAction::ViaBot if message.via_bot
        if dice = message.dice
          actions << UpdateAction::Dice if dice.emoji == "🎲"
          actions << UpdateAction::Dart if dice.emoji == "🎯"
          actions << UpdateAction::Basketball if dice.emoji == "🏀"
          actions << UpdateAction::Soccerball if dice.emoji == "⚽️"
          actions << UpdateAction::Football if dice.emoji == "⚽️"
          actions << UpdateAction::SlotMachine if dice.emoji == "🎰"
        end
      end

      actions << UpdateAction::EditedMessage if update.edited_message
      actions << UpdateAction::ChannelPost if update.channel_post
      actions << UpdateAction::EditedChannelPost if update.edited_channel_post
      actions << UpdateAction::InlineQuery if update.inline_query
      actions << UpdateAction::ChosenInlineResult if update.chosen_inline_result
      actions << UpdateAction::CallbackQuery if update.callback_query
      actions << UpdateAction::ShippingQuery if update.shipping_query
      actions << UpdateAction::PreCheckoutQuery if update.pre_checkout_query
      actions << UpdateAction::Poll if update.poll
      actions << UpdateAction::PollAnswer if update.poll_answer

      actions
    end
  end
end
