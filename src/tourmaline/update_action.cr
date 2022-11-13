module Tourmaline
  # The available event types for `EventHandler`.
  enum UpdateAction
    Update
    Message
    ThreadMessage
    ReplyMessage
    EditedMessage
    ForwardedMessage
    CallbackQuery
    InlineQuery
    ShippingQuery
    PreCheckoutQuery
    ChosenInlineResult
    ChannelPost
    EditedChannelPost
    MyChatMember
    ChatMember

    ViaBot
    Text
    Caption
    Animation
    Audio
    Document
    Photo
    Sticker
    Video
    Voice
    Contact
    Location
    Venue
    MediaGroup
    NewChatMembers
    LeftChatMember
    NewChatTitle
    NewChatPhoto
    DeleteChatPhoto
    GroupChatCreated
    MessageAutoDeleteTimerChanged
    MigrateToChatId
    SupergroupChatCreated
    ChannelChatCreated
    MigrateFromChatId
    PinnedMessage
    Game
    Poll
    VideoNote
    Invoice
    SuccessfulPayment
    ConnectedWebsite
    PassportData
    PollAnswer
    ProximityAlertTriggered
    ForumTopicCreated
    ForumTopicClosed
    ForumTopicReopened
    VideoChatScheduled
    VideoChatStarted
    VideoChatEnded
    VideoChatParticipantsInvited
    WebAppData
    ReplyMarkup

    Dice        # 🎲
    Dart        # 🎯
    Basketball  # 🏀
    Football    # ⚽️
    Soccerball  # ⚽️ but American
    SlotMachine # 🎰
    Bowling     # 🎳

    BotMessage
    UserMessage
    ChannelMessage
    ChannelForwardMessage
    AnonymousAdminMessage

    MentionEntity
    TextMentionEntity
    HashtagEntity
    CashtagEntity
    BotCommandEntity
    UrlEntity
    EmailEntity
    PhoneNumberEntity
    BoldEntity
    ItalicEntity
    CodeEntity
    PreEntity
    TextLinkEntity
    UnderlineEntity
    StrikethroughEntity
    SpoilerEntity

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
        actions << UpdateAction::ThreadMessage if message.message_thread_id
        actions << UpdateAction::ReplyMessage if message.reply_message
        actions << UpdateAction::ForwardedMessage if message.forward_date

        if chat = message.chat
          actions << UpdateAction::PinnedMessage if chat.pinned_message
        end

        actions << UpdateAction::ViaBot if message.via_bot
        actions << UpdateAction::Text if message.text
        actions << UpdateAction::Caption if message.caption
        actions << UpdateAction::Animation if message.animation
        actions << UpdateAction::Audio if message.audio
        actions << UpdateAction::Document if message.document
        actions << UpdateAction::Photo if message.photo.size > 0
        actions << UpdateAction::Sticker if message.sticker
        actions << UpdateAction::Video if message.video
        actions << UpdateAction::Voice if message.voice
        actions << UpdateAction::Contact if message.contact
        actions << UpdateAction::Location if message.location
        actions << UpdateAction::Venue if message.venue
        actions << UpdateAction::MediaGroup if message.media_group_id
        actions << UpdateAction::NewChatMembers if message.new_chat_members.size > 0
        actions << UpdateAction::LeftChatMember if message.left_chat_member
        actions << UpdateAction::NewChatTitle if message.new_chat_title
        actions << UpdateAction::NewChatPhoto if message.new_chat_photo.size > 0
        actions << UpdateAction::DeleteChatPhoto if message.delete_chat_photo
        actions << UpdateAction::GroupChatCreated if message.group_chat_created
        actions << UpdateAction::MessageAutoDeleteTimerChanged if message.message_auto_delete_timer_changed
        actions << UpdateAction::MigrateToChatId if message.migrate_from_chat_id
        actions << UpdateAction::SupergroupChatCreated if message.supergroup_chat_created
        actions << UpdateAction::ChannelChatCreated if message.channel_chat_created
        actions << UpdateAction::MigrateFromChatId if message.migrate_from_chat_id
        actions << UpdateAction::Game if message.game
        actions << UpdateAction::Poll if message.poll
        actions << UpdateAction::VideoNote if message.video_note
        actions << UpdateAction::Invoice if message.invoice
        actions << UpdateAction::SuccessfulPayment if message.successful_payment
        actions << UpdateAction::ConnectedWebsite if message.connected_website
        actions << UpdateAction::PassportData if message.passport_data
        actions << UpdateAction::ProximityAlertTriggered if message.proximity_alert_triggered
        actions << UpdateAction::VideoChatScheduled if message.video_chat_scheduled
        actions << UpdateAction::ForumTopicCreated if message.forum_topic_created
        actions << UpdateAction::ForumTopicClosed if message.forum_topic_closed
        actions << UpdateAction::ForumTopicReopened if message.forum_topic_reopened
        actions << UpdateAction::VideoChatStarted if message.video_chat_started
        actions << UpdateAction::VideoChatEnded if message.video_chat_ended
        actions << UpdateAction::VideoChatParticipantsInvited if message.video_chat_participants_invited
        actions << UpdateAction::WebAppData if message.web_app_data
        actions << UpdateAction::ReplyMarkup if message.reply_markup

        if dice = message.dice
          case dice.emoji
          when "🎲"
            actions << UpdateAction::Dice
          when "🎯"
            actions << UpdateAction::Dart
          when "🏀"
            actions << UpdateAction::Basketball
          when "⚽️"
            actions << UpdateAction::Football
            actions << UpdateAction::Soccerball
          when "🎰"
            actions << UpdateAction::SlotMachine
          when "🎳"
            actions << UpdateAction::Bowling
          end
        end

        case message.sender_type
        when Tourmaline::Message::SenderType::Bot
          actions << UpdateAction::BotMessage
        when Tourmaline::Message::SenderType::Channel
          actions << UpdateAction::ChannelMessage
        when Tourmaline::Message::SenderType::User
          actions << UpdateAction::UserMessage
        when Tourmaline::Message::SenderType::AnonymousAdmin
          actions << UpdateAction::AnonymousAdminMessage
        when Tourmaline::Message::SenderType::ChannelForward
          actions << UpdateAction::ChannelForwardMessage
        end

        entities = (message.entities + message.caption_entities).map(&.type).uniq
        entities.each do |ent|
          case ent
          when "mention"
            actions << UpdateAction::MentionEntity
          when "text_mention"
            actions << UpdateAction::TextMentionEntity
          when "hashtag"
            actions << UpdateAction::HashtagEntity
          when "cashtag"
            actions << UpdateAction::CashtagEntity
          when "bot_command"
            actions << UpdateAction::BotCommandEntity
          when "url"
            actions << UpdateAction::UrlEntity
          when "email"
            actions << UpdateAction::EmailEntity
          when "phone_number"
            actions << UpdateAction::PhoneNumberEntity
          when "bold"
            actions << UpdateAction::BoldEntity
          when "italic"
            actions << UpdateAction::ItalicEntity
          when "code"
            actions << UpdateAction::CodeEntity
          when "pre"
            actions << UpdateAction::PreEntity
          when "text_link"
            actions << UpdateAction::TextLinkEntity
          when "underline"
            actions << UpdateAction::UnderlineEntity
          when "strikethrough"
            actions << UpdateAction::StrikethroughEntity
          when "spoiler"
            actions << UpdateAction::SpoilerEntity
          end
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
      actions << UpdateAction::MyChatMember if update.my_chat_member
      actions << UpdateAction::ChatMember if update.chat_member

      actions
    end
  end
end
