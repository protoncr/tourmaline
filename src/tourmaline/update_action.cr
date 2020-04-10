module Tourmaline
  enum UpdateAction
    Update
    Message
    EditedMessage
    CallbackQuery
    InlineQuery
    ShippingQuery
    PreCheckoutQuery
    ChosenInlineResult
    ChannelPost
    EditedChannelPost

    Text
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
    Dice

    def to_s
      super.to_s.underscore
    end

    def self.to_a
      {{ @type.constants.map { |c| c.stringify.id } }}
    end
  end
end
