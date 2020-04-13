module Tourmaline
  class Client
    # Use this method to send `.webp` stickers.
    # On success, the sent `Message` is returned.
    #
    # See: https://core.telegram.org/bots/api#stickers for more info.
    def send_sticker(
      chat_id : Int32 | String,
      sticker : InputFile | String,
      disable_notification : Bool? = nil,
      reply_to_message_id : Int32? = nil,
      reply_markup = nil
    )
      response = request("sendSticker", {
        chat_id:               chat_id,
        sticker:               sticker,
        disable_notifications: disable_notifications,
        reply_to_message_id:   reply_to_message_id,
        reply_markup:          reply_markup,
      })

      Message.from_json(response)
    end

    # Use this method to get a sticker set.
    # On success, a `StickerSet` object is returned.
    def get_sticker_set(name : String)
      response = request("getStickerSet", {
        name: name,
      })

      StickerSet.from_json(response)
    end

    # Use this method to set a new group sticker set for a supergroup. The bot must
    # be an administrator in the chat for this to work and must have the
    # appropriate admin rights. Use the field can_set_sticker_set
    # optionally returned in `#get_chat` requests to check if the
    # bot can use this method.
    # Returns `true` on success.
    def set_chat_sticker_set(chat_id, sticker_set_name)
      response = request("setChatStickerSet", {
        chat_id:          chat_id,
        sticker_set_name: sticker_set_name,
      })

      response == "true"
    end

    # Use this method to add a new sticker to a set created by the bot.
    # Returns `true` on success.
    def add_sticker_to_set(
      user_id,
      name,
      emojis,
      png_sticker = nil,
      tgs_sticker = nil,
      mask_position = nil
    )
      raise "A sticker is required, but none was provided" unless png_sticker || tgs_sticker

      response = request("addStickerToSet", {
        user_id:       user_id,
        name:          name,
        png_sticker:   png_sticker,
        tgs_sticker:   tgs_sticker,
        emojis:        emojis,
        mask_position: mask_position,
      })

      response == "true"
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
      contains_masks = nil,
      mask_position = nil
    )
      raise "A sticker is required, but none was provided" unless png_sticker || tgs_sticker

      response = request("createNewStickerSet", {
        user_id:        user_id,
        name:           name,
        title:          title,
        png_sticker:    png_sticker,
        tgs_sticker:    tgs_sticker,
        emojis:         emojis,
        contains_masks: contains_masks,
        mask_position:  mask_position,
      })

      response == "true"
    end

    # Use this method to delete a group sticker set from a supergroup. The bot must be
    # an administrator in the chat for this to work and must have the appropriate
    # admin rights. Use the field can_set_sticker_set optionally returned in
    # `#get_chat` requests to check if the bot can use this method.
    # Returns `true` on success.
    def delete_chat_sticker_set(chat_id)
      response = request("deleteChatStickerSet", {
        chat_id: chat_id,
      })

      response == "true"
    end

    # Use this method to delete a sticker from a set created by the bot.
    # Returns `true` on success.
    def delete_sticker_from_set(sticker)
      response = request("deleteStickerFromSet", {
        sticker: sticker,
      })

      response == "true"
    end

    # Use this method to move a sticker in a set created by the bot to a specific position.
    # Returns `true` on success.
    def set_sticker_position_in_set(sticker, position)
      response = request("setStickerPositionInSet", {
        sticker:  sticker,
        position: position,
      })

      response == "true"
    end

    # Use this method to upload a .png file with a sticker for later use in
    # `#create_new_sticker_set` and `#add_sticker_to_set` methods (can be
    # used multiple times).
    # Returns the uploaded `TFile` on success.
    def upload_sticker_file(user_id, png_sticker)
      response = request("uploadStickerFile", {
        user_id:     user_id,
        png_sticker: png_sticker,
      })

      TFile.from_json(response)
    end

    # Use this method to set the thumbnail of a sticker set. Animated thumbnails can be
    # set for animated sticker sets only.
    # Returns `true` on success.
    def set_sticker_set_thumb(name, user, thumb = nil)
      user_id = user.is_a?(Int) ? user : user.id

      response = request("setStickerSetThumb", {
        name: name,
        user_id: user_id,
        thumb: thumb
      })

      respose == "true"
    end
  end
end
