module Tourmaline
  module Helpers
    extend self

    DEFAULT_EXTENSIONS = {
      audio:      "mp3",
      photo:      "jpg",
      sticker:    "webp",
      video:      "mp4",
      animation:  "mp4",
      video_note: "mp4",
      voice:      "ogg",
    }

    def actions_from_update(update : Update)
      actions = [] of UpdateAction

      actions << UpdateAction::Update

      if message = update.message
        actions << UpdateAction::Message

        if chat = message.chat
          actions << UpdateAction::PinnedMessage if chat.pinned_message
        end

        actions << UpdateAction::Text if message.text
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
        # actions << UpdateAction::PassportData if message.passport_data
        actions << UpdateAction::Poll if message.poll
        if dice = message.dice
          actions << UpdateAction::Dice if dice.emoji == "🎲"
          actions << UpdateAction::Dart if dice.emoji == "🎯"
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

    def format_html(text = "", entities = [] of MessageEntity)
      available = entities.dup
      opened = [] of MessageEntity
      result = [] of String | Char

      text.chars.each_index do |i|
        loop do
          index = available.index { |e| e.offset == i }
          break if index.nil?
          entity = available[index]

          case entity.type
          when "bold"
            result << "<b>"
          when "italic"
            result << "<i>"
          when "code"
            result << "<code>"
          when "pre"
            if entity.language
              result << "<pre language=\"#{entity.language}\">"
            else
              result << "<pre>"
            end
          when "strikethrough"
            result << "<s>"
          when "underline"
            result << "<u>"
          when "text_mention"
            if user = entity.user
              result << "<a href=\"tg://user?id=#{user.id}\">"
            end
          when "text_link"
            result << "<a href=\"#{entity.url}\">"
          end

          opened.unshift(entity)
          available.delete_at(index)
        end

        result << text[i]

        loop do
          index = opened.index { |e| e.offset + e.length - 1 == i }
          break if index.nil?
          entity = opened[index]

          case entity.type
          when "bold"
            result << "</b>"
          when "italic"
            result << "</i>"
          when "code"
            result << "</code>"
          when "pre"
            result << "</pre>"
          when "strikethrough"
            result << "</s>"
          when "underline"
            result << "</u>"
          when "text_mention"
            if entity.user
              result << "</a>"
            end
          when "text_link"
            result << "</a>"
          end

          opened.delete_at(index)
        end
      end

      result.join("")
    end
  end
end
