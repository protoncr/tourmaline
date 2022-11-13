module Tourmaline
  class Client
    module StickerMethods
      # Use this method to send `.webp` stickers.
      # On success, the sent `Message` is returned.
      #
      # See: https://core.telegram.org/bots/api#stickers for more info.
      def send_sticker(
        chat,
        sticker,
        message_thread_id = nil,
        disable_notification = nil,
        reply_to_message = nil,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Message, "sendSticker", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          sticker:              sticker,
          disable_notification: disable_notification,
          reply_to_message_id:  reply_to_message_id,
          reply_markup:         reply_markup,
        })
      end

      # Use this method to get a sticker set.
      # On success, a `StickerSet` object is returned.
      def get_sticker_set(name : String)
        request(Message, "getStickerSet", {
          name: name,
        })
      end

      # Use this method to get information about custom emoji stickers by their identifiers.
      # Returns an Array of Sticker objects.
      def get_custom_emoji_stickers(custom_emoji_ids : Array(String))
        request(Array(Sticker), "getCustomEmojiStickers", {
          custom_emoji_ids: custom_emoji_ids,
        })
      end

      # Use this method to set a new group sticker set for a supergroup. The bot must
      # be an administrator in the chat for this to work and must have the
      # appropriate admin rights. Use the field can_set_sticker_set
      # optionally returned in `#get_chat` requests to check if the
      # bot can use this method.
      # Returns `true` on success.
      def set_chat_sticker_set(chat_id, sticker_set_name)
        request(Bool, "setChatStickerSet", {
          chat_id:          chat_id,
          sticker_set_name: sticker_set_name,
        })
      end

      # Use this method to add a new sticker to a set created by the bot.
      # Returns `true` on success.
      def add_sticker_to_set(
        user_id,
        name,
        emojis,
        png_sticker = nil,
        tgs_sticker = nil,
        webm_sticker = nil,
        mask_position = nil
      )
        raise "A sticker is required, but none was provided" unless png_sticker || tgs_sticker || webm_sticker

        request(bool, "addStickerToSet", {
          user_id:       user_id,
          name:          name,
          png_sticker:   png_sticker,
          tgs_sticker:   tgs_sticker,
          webm_sticker:  webm_sticker,
          emojis:        emojis,
          mask_position: mask_position,
        })
      end

      # Use this method to create new sticker set owned by a user. The bot will be able to
      # edit the created sticker set. You must use exactly one of the fields `png_sticker` or `tgs_sticker`.
      # Returns `true` on success.
      def create_new_sticker_set(
        user_id,
        name,
        title,
        emojis,
        png_sticker = nil,
        tgs_sticker = nil,
        webm_sticker = nil,
        sticker_type = nil,
        mask_position = nil
      )
        raise "A sticker is required, but none was provided" unless png_sticker || tgs_sticker || webm_sticker

        request(Bool, "createNewStickerSet", {
          user_id:       user_id,
          name:          name,
          title:         title,
          png_sticker:   png_sticker,
          tgs_sticker:   tgs_sticker,
          webm_sticker:  webm_sticker,
          sticker_type:  sticker_type,
          emojis:        emojis,
          mask_position: mask_position,
        })
      end

      # Use this method to delete a group sticker set from a supergroup. The bot must be
      # an administrator in the chat for this to work and must have the appropriate
      # admin rights. Use the field can_set_sticker_set optionally returned in
      # `#get_chat` requests to check if the bot can use this method.
      # Returns `true` on success.
      def delete_chat_sticker_set(chat_id)
        request(Bool, "deleteChatStickerSet", {
          chat_id: chat_id,
        })
      end

      # Use this method to delete a sticker from a set created by the bot.
      # Returns `true` on success.
      def delete_sticker_from_set(sticker)
        request(Bool, "deleteStickerFromSet", {
          sticker: sticker,
        })
      end

      # Use this method to move a sticker in a set created by the bot to a specific position.
      # Returns `true` on success.
      def set_sticker_position_in_set(sticker, position)
        request(Bool, "setStickerPositionInSet", {
          sticker:  sticker,
          position: position,
        })
      end

      # Use this method to upload a .png file with a sticker for later use in
      # `#create_new_sticker_set` and `#add_sticker_to_set` methods (can be
      # used multiple times).
      # Returns the uploaded `TFile` on success.
      def upload_sticker_file(user_id, png_sticker)
        request(TFile, "uploadStickerFile", {
          user_id:     user_id,
          png_sticker: png_sticker,
        })
      end

      # Use this method to set the thumbnail of a sticker set. Animated thumbnails can be
      # set for animated sticker sets only.
      # Returns `true` on success.
      def set_sticker_set_thumb(name, user, thumb = nil)
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "setStickerSetThumb", {
          name:    name,
          user_id: user_id,
          thumb:   thumb,
        })
      end
    end
  end
end
