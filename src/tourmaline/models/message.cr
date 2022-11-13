require "json"
require "./message_entity"

module Tourmaline
  # # This object represents a Telegram user or bot.
  class Message
    include JSON::Serializable
    include Tourmaline::Model

    getter message_id : Int64

    getter message_thread_id : Int64?

    getter from : User?

    getter sender_chat : Chat?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter date : Time

    getter chat : Chat

    getter forward_from : User?

    getter forward_from_chat : Chat?

    getter forward_from_message_id : Int64?

    getter forward_signature : String?

    getter forward_sender_name : String?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter forward_date : Time?

    @[JSON::Field(key: "is_topic_message")]
    getter? topic_message : Bool?

    @[JSON::Field(key: "is_automatic_forward")]
    getter? automatic_forward : Bool?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter edit_date : Time?

    @[JSON::Field(key: "reply_to_message")]
    getter reply_message : Message?

    getter via_bot : User?

    @[JSON::Field(converter: Time::EpochConverter)]
    getter edit_date : Time?

    getter? has_protected_content : Bool?

    getter media_group_id : String?

    getter author_signature : String?

    getter text : String?

    getter entities : Array(MessageEntity) = [] of Tourmaline::MessageEntity

    getter animation : Animation?

    getter audio : Audio?

    getter document : Document?

    getter photo : Array(PhotoSize) = [] of Tourmaline::PhotoSize

    getter sticker : Sticker?

    getter video : Video?

    getter video_note : VideoNote?

    getter voice : Voice?

    getter caption : String?

    getter caption_entities : Array(MessageEntity) = [] of Tourmaline::MessageEntity

    getter contact : Contact?

    getter dice : Dice?

    getter game : Game?

    getter poll : Poll?

    getter venue : Venue?

    getter location : Location?

    getter new_chat_members : Array(User) = [] of Tourmaline::User

    getter left_chat_member : User?

    getter new_chat_title : String?

    getter new_chat_photo : Array(PhotoSize) = [] of Tourmaline::PhotoSize

    getter delete_chat_photo : Bool?

    getter group_chat_created : Bool?

    getter supergroup_chat_created : Bool?

    getter channel_chat_created : Bool?

    getter message_auto_delete_timer_changed : MessageAutoDeleteTimerChanged?

    getter migrate_to_chat_id : Int64?

    getter migrate_from_chat_id : Int64?

    getter pinned_message : Message?

    getter invoice : Invoice?

    getter successful_payment : SuccessfulPayment?

    getter connected_website : String?

    getter passport_data : PassportData?

    getter proximity_alert_triggered : ProximityAlertTriggered?

    getter forum_topic_created : ForumTopicCreated?

    getter forum_topic_closed : ForumTopicClosed?

    getter forum_topic_reopened : ForumTopicReopened?

    getter video_chat_scheduled : VideoChatScheduled?

    getter video_chat_started : VideoChatStarted?

    getter video_chat_ended : VideoChatEnded?

    getter video_chat_participants_invited : VideoChatParticipantsInvited?

    getter reply_markup : InlineKeyboardMarkup?

    getter web_app_data : WebAppData?

    # USER API ONLY
    getter? outgoing : Bool?

    # USER API ONLY
    getter views : Int32?

    # USER API ONLY
    getter forwards : Int32?

    def file
      if animation
        {:animation, animation}
      elsif audio
        {:audio, audio}
      elsif document
        {:document, document}
      elsif sticker
        {:sticker, sticker}
      elsif video
        {:video, video}
      elsif video_note
        {:video_note, video_note}
      elsif photo.first?
        {:photo, photo.first}
      else
        {nil, nil}
      end
    end

    def link
      if chat.username
        "https://t.me/#{chat.username}/#{message_id}"
      else
        "https://t.me/c/#{chat.id}/#{message_id}"
      end
    end

    def text_entities
      text = self.caption || self.text
      [entities, caption_entities].flatten.reduce({} of MessageEntity => String) do |acc, ent|
        acc[ent] = text.to_s[ent.offset, ent.length]
        acc
      end
    end

    def raw_text(parse_mode : ParseMode = :markdown, escape : Bool = false)
      if txt = text
        Helpers.unparse_text(txt, entities, parse_mode, escape)
      end
    end

    def raw_caption(parse_mode : ParseMode = :markdown, escape : Bool = false)
      if txt = caption
        Helpers.unparse_text(txt, entities, parse_mode, escape)
      end
    end

    def users
      users = [] of User?
      users << self.from
      users << self.forward_from
      users << self.left_chat_member
      users.concat(self.new_chat_members)
      users.compact.uniq
    end

    def users(&block : User ->)
      self.users.each { |u| block.call(u) }
    end

    def chats
      chats = [] of Chat?
      chats << self.chat
      chats << self.sender_chat
      chats << self.forward_from_chat
      if reply_message = self.reply_message
        chats.concat(reply_message.chats)
      end
      chats.compact.uniq
    end

    def chats(&block : Chat ->)
      self.chats.each { |c| block.call(c) }
    end

    # Delete the message. See `Tourmaline::Client#delete_message`.
    def delete
      client.delete_message(chat, message_id)
    end

    # Edits the message's media. See `Tourmaline::Client#edit_message_media`
    def edit_media(media, **kwargs)
      client.edit_message_media(chat, media, **kwargs, message: message_id)
    end

    # Edits the message's caption. See `Tourmaline::Client#edit_message_caption`
    def edit_caption(caption, **kwargs)
      client.edit_message_caption(chat, caption, **kwargs, message: message_id)
    end

    # Set the reply markup for the message. See `Tourmaline::Client#edit_message_reply_markup`.
    def edit_reply_markup(reply_markup)
      client.edit_message_reply_markup(chat, message: message_id, reply_markup: reply_markup)
    end

    # Edits the text of a message. See `Tourmaline::Client#edit_message_text`.
    def edit_text(text, **kwargs)
      client.edit_message_text(text, chat, **kwargs, message: message_id)
    end

    # Edits the message's live_location. See `Tourmaline::Client#edit_message_live_location`
    def edit_live_location(lat, long, **kwargs)
      client.edit_message_live_location(chat, lat, long, **kwargs, message: message_id)
    end

    # Forward the message to another chat. See `Tourmaline::Client#forward_message`.
    def forward(to_chat, **kwargs)
      client.forward_message(to_chat, chat, message_id, **kwargs)
    end

    # Pin the message. See `Tourmaline::Client#pin_chat_message`.
    def pin(**kwargs)
      client.pin_chat_message(chat, message_id, **kwargs)
    end

    # Unpin the message. See `Tourmaline::Client#unpin_chat_message`.
    def unpin(**kwargs)
      client.unpin_chat_message(chat, message_id, **kwargs)
    end

    # Reply to a message. See `Tourmaline::Client#send_message`.
    def reply(message, **kwargs)
      client.send_message(chat, message, **kwargs, reply_to_message: message_id)
    end

    # Respond to a message. See `Tourmaline::Client#send_message`.
    def respond(message, **kwargs)
      client.send_message(chat, message, **kwargs)
    end

    {% for content_type in %w[audio animation contact document location sticker photo media_group venu video video_note voice invoice poll dice dart basketball] %}
      def reply_with_{{content_type.id}}(*args, **kwargs)
        client.send_{{content_type.id}}(chat, *args, **kwargs, reply_to_message: message_id)
      end

      def respond_with_{{content_type.id}}(*args, **kwargs)
        client.send_{{content_type.id}}(chat, *args, **kwargs)
      end
    {% end %}

    def edit_live_location(latitude, longitude, **kwargs)
      client.edit_message_live_location(chat, latitude, longitude, **kwargs, message: message_id)
    end

    def stop_live_location(**kwargs)
      client.stop_message_live_location(chat, message_id, **kwargs)
    end

    def sender_type
      if automatic_forward?
        SenderType::ChannelForward
      elsif sc = sender_chat
        if sc.id == chat.id
          SenderType::AnonymousAdmin
        else
          SenderType::Channel
        end
      elsif from.try(&.bot?)
        SenderType::Bot
      else
        SenderType::User
      end
    end

    enum SenderType
      Bot
      User
      Channel
      ChannelForward
      AnonymousAdmin
    end
  end
end
