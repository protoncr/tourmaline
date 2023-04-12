module Tourmaline
  class Message
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

    def text_entities(type : String)
      text_entities.select { |ent, text| ent.type == type }
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

    def sender_type
      if is_automatic_forward?
        SenderType::ChannelForward
      elsif sc = sender_chat
        if sc.id == chat.id
          SenderType::AnonymousAdmin
        else
          SenderType::Channel
        end
      elsif from.try(&.is_bot?)
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
