require "uri"

module Tourmaline
  class Client
    getter polling : Bool = false
    getter next_offset : Int64 = 0.to_i64

    # Convenience method to check if this bot is an admin in
    # the current chat. See `Client#get_chat_administrators`
    # for more info.
    def is_admin?(chat_id)
      admins = get_chat_administrators(chat_id)
      admins.any? { |a| a.user.id = @bot_info.id }
    end

    # A simple method for testing your bot's auth token. Requires
    # no parameters. Returns basic information about the bot
    # in form of a `User` object.
    def get_me
      response = request("getMe")
      User.from_json(response)
    end

    # Use this method to receive incoming updates using long polling
    # ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)).
    # An `Array` of `Update` objects is returned.
    def get_updates(
      offset = @next_offset,
      limit = nil,
      timeout = @updates_timeout,
      allowed_updates = @allowed_updates
    )
      response = request("getUpdates", {
        offset:          offset,
        limit:           limit,
        timeout:         timeout,
        allowed_updates: allowed_updates,
      })

      updates = Array(Update).from_json(response)

      if !updates.empty?
        @next_offset = updates.last.update_id + 1
      end

      updates
    end

    # Use this method to send answers to callback queries sent from
    # inline keyboards. The answer will be displayed to the user
    # as a notification at the top of the chat screen or as
    # an alert. On success, `true` is returned.
    #
    # > Alternatively, the user can be redirected to the specified
    # > Game URL (`url`). For this option to work, you must first
    # > create a game for your bot via @Botfather and accept the
    # > terms. Otherwise, you may use links like
    # > [t.me/your_bot?start=XXXX](https://t.me/your_bot?start=XXXX)
    # > that open your bot with a parameter.
    def answer_callback_query(
      callback_query_id,
      text = nil,
      show_alert = nil,
      url = nil,
      cache_time = nil
    )
      response = request("answerCallbackQuery", {
        callback_query_id: callback_query_id,
        text:              text,
        show_alert:        show_alert,
        url:               url,
        cache_time:        cache_time,
      })

      response == "true"
    end

    # Use this method to send answers to an inline query.
    # On success, True is returned. No more than
    # **50** results per query are allowed.
    def answer_inline_query(
      inline_query_id,
      results,
      cache_time = nil,
      is_personal = nil,
      next_offset = nil,
      switch_pm_text = nil,
      switch_pm_parameter = nil
    )
      response = request("answerInlineQuery", {
        inline_query_id:     inline_query_id,
        results:             results.to_json,
        cache_time:          cache_time,
        is_personal:         is_personal,
        next_offset:         next_offset,
        switch_pm_text:      switch_pm_text,
        switch_pm_parameter: switch_pm_parameter,
      })

      response == "true"
    end

    # Use this method to delete a `Message`, including service messages,
    # with the following limitations:
    # - A message can only be deleted if it was sent less than 48 hours ago.
    # - Bots can delete outgoing messages in private chats, groups, and supergroups.
    # - Bots can delete incoming messages in private chats.
    # - Bots granted can_post_messages permissions can delete outgoing messages in channels.
    # - If the bot is an administrator of a group, it can delete any message there.
    # - If the bot has `can_delete_messages` permission in a supergroup or a
    #   channel, it can delete any message there.
    # Returns `true` on success.
    def delete_message(chat, message)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id

      response = request("deleteMessage", {
        chat_id:    chat_id,
        message_id: message_id,
      })

      response == "true"
    end

    # Use this method to edit captions of messages. On success,
    # if edited message is sent by the bot, the edited
    # `Message` is returned, otherwise `true`
    # is returned.
    def edit_message_caption(
      chat,
      caption,
      message = nil,
      inline_message = nil,
      parse_mode = ParseMode::Normal,
      reply_markup = nil
    )
      if !message && !inline_message
        raise "A message_id or inline_message_id is required"
      end

      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id
      inline_message_id = inline_message.is_a?(Int32 | Int64 | Nil) ? inline_message : inline_message.id
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("editMesasageCaption", {
        chat_id:           chat_id,
        caption:           caption,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        parse_mode:        parse_mode,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      response.is_a?(String) ? response == "true" : Message.from_json(response)
    end

    # Use this method to edit only the reply markup of messages.
    # On success, if edited message is sent by the bot, the
    # edited `Message` is returned, otherwise `true` is
    # returned.
    def edit_message_reply_markup(
      chat,
      message = nil,
      inline_message = nil,
      reply_markup = nil
    )
      if !message && !inline_message
        raise "A message_id or inline_message_id is required"
      end

      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id
      inline_message_id = inline_message.is_a?(Int32 | Int64 | Nil) ? inline_message : inline_message.id

      response = request("editMesasageReplyMarkup", {
        chat_id:           chat_id,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      response.is_a?(String) ? response == "true" : Message.from_json(response)
    end

    # Use this method to edit text and game messages. On success, if
    # edited message is sent by the bot, the edited `Message`
    # is returned, otherwise `true` is returned.
    def edit_message_text(
      chat,
      text,
      message = nil,
      inline_message = nil,
      parse_mode = ParseMode::Normal,
      disable_link_preview = false,
      reply_markup = nil
    )
      if !message && !inline_message
        raise "A message_id or inline_message_id is required"
      end

      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id
      inline_message_id = inline_message.is_a?(Int32 | Int64 | Nil) ? inline_message : inline_message.id
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("editMessageText", {
        chat_id:                  chat_id,
        message_id:               message_id,
        inline_message_id:        inline_message_id,
        text:                     text,
        parse_mode:               parse_mode,
        disable_web_page_preview: disable_link_preview,
        reply_markup:             reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to forward messages of any kind. On success,
    # the sent `Message` is returned.
    def forward_message(
      chat,
      from_chat,
      message,
      disable_notification = false
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int) ? message : message.id
      from_chat_id = from_chat.is_a?(Int) ? from_chat : from_chat.id

      response = request("forwardMessage", {
        chat_id:              chat_id,
        from_chat_id:         from_chat_id,
        message_id:           message_id,
        disable_notification: disable_notification,
      })

      Message.from_json(response)
    end

    # Use this method to get up to date information about the chat
    # (current name of the user for one-on-one conversations,
    # current username of a user, group or channel, etc.).
    # Returns a `Chat` object on success.
    def get_chat(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("getChat", {
        chat_id: chat_id,
      })

      Chat.from_json(response)
    end

    # Use this method to get a list of administrators in a chat. On success,
    # returns an `Array` of `ChatMember` objects that contains information
    # about all chat administrators except other bots. If the chat is a
    # group or a supergroup and no administrators were appointed,
    # only the creator will be returned.
    def get_chat_administrators(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("getChatAdministrators", {
        chat_id: chat_id,
      })

      Array(ChatMember).from_json(response)
    end

    # Use this method to get information about a member of a chat. Returns a
    # `ChatMember` object on success.
    def get_chat_member(chat, user)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id

      response = request("getChatMember", {
        chat_id: chat_id,
        user_id: user_id,
      })

      chat_member = ChatMember.from_json(response)
      chat_member.chat_id = chat_id
      chat_member
    end

    # Use this method to get the number of members in a chat.
    # Returns `Int32` on success.
    def get_chat_members_count(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("getChatMembersCount", {
        chat_id: chat_id,
      })

      response.to_i32
    end

    # Use this method to get basic info about a file and prepare it for downloading.
    # For the moment, bots can download files of up to **20MB** in size. On success,
    # a `TFile` object is returned. The file can then be downloaded via the
    # link `https://api.telegram.org/file/bot<token>/<file_path>`, where
    # `<file_path>` is taken from the response. It is guaranteed that
    # the link will be valid for at least 1 hour. When the link
    # expires, a new one can be requested by calling `#get_file` again.
    #
    # To simplify retrieving a link for a file, use the `#get_file_link` method.
    def get_file(file_id)
      response = request("getFile", {
        file_id: file_id,
      })

      TFile.from_json(response)
    end

    # Returns a download link for a `TFile`.
    def get_file_link(file)
      if file_path = file.file_path
        ::File.join("#{API_URL}/file/bot#{@api_key}", file_path)
      end
    end

    # Use this method to get a list of profile pictures for a user.
    # Returns a `UserProfilePhotos` object.
    def get_user_profile_photos(
      user,
      offset = nil,
      limit = nil
    )
      user_id = user.is_a?(Int) ? user : user.id

      response = request("getUserProfilePhotos", {
        user_id: user_id,
        offset:  offset,
        limit:   limit,
      })

      UserProfilePhotos.from_json(response)
    end

    # Use this method to kick a user from a group, a supergroup or a channel.
    # In the case of supergroups and channels, the user will not be able to
    # return to the group on their own using invite links, etc., unless
    # unbanned first. The bot must be an administrator in the chat
    # for this to work and must have the appropriate admin
    # rights. Returns `true` on success.
    #
    # > Note: In regular groups (non-supergroups), this method will only work
    # > if the `All Members Are Admins` setting is off in the target group.
    # > Otherwise members may only be removed by the group's creator or
    # > by the member that added them.
    def kick_chat_member(
      chat,
      user,
      until_date = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id
      until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)

      response = request("kickChatMember", {
        chat_id:    chat_id,
        user_id:    user_id,
        until_date: until_date,
      })

      response == "true"
    end

    # Use this method to unban a previously kicked user in a supergroup
    # or channel. The user will not return to the group or channel
    # automatically, but will be able to join via link, etc.
    # The bot must be an administrator for this to work.
    # Returns `true` on success.
    def unban_chat_member(
      chat,
      user
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id

      response = request("unbanChatMember", {
        chat_id: chat_id,
        user_id: user_id,
      })

      response == "true"
    end

    # Use this method to unban a previously kicked user in a supergroup or
    # channel. The user will not return to the group or channel
    # automatically, but will be able to join via link, etc.
    # The bot must be an administrator for this to work.
    # Returns `true` on success.
    def restrict_chat_member(
      chat,
      user,
      permissions,
      until_date = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id
      until_date = until_date.to_unix unless until_date.is_a?(Int)
      permissions = permissions.is_a?(NamedTuple) ? ChatPermissions.new(**permissions) : permissions

      response = request("restrictChatMember", {
        chat_id:     chat_id,
        user_id:     user_id,
        until_date:  until_date,
        permissions: permissions.to_json,
      })

      response == "true"
    end

    # Use this method to promote or demote a user in a supergroup or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the appropriate admin rights. Pass False for all boolean
    # parameters to demote a user.
    # Returns `true` on success.
    def promote_chat_member(
      chat,
      user,
      until_date = nil,
      can_change_info = nil,
      can_post_messages = nil,
      can_edit_messages = nil,
      can_delete_messages = nil,
      can_invite_users = nil,
      can_restrict_members = nil,
      can_pin_messages = nil,
      can_promote_members = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id

      response = request("promoteChatMember", {
        chat_id:              chat_id,
        user_id:              user_id,
        until_date:           until_date,
        can_change_info:      can_change_info,
        can_post_messages:    can_post_messages,
        can_edit_messages:    can_edit_messages,
        can_delete_messages:  can_delete_messages,
        can_invite_users:     can_invite_users,
        can_restrict_members: can_restrict_members,
        can_pin_messages:     can_pin_messages,
        can_promote_members:  can_promote_members,
      })

      response == "true"
    end

    # Use this method to generate a new invite link for a chat; any previously
    # generated link is revoked. The bot must be an administrator in the chat
    # for this to work and must have the appropriate admin rights.
    # Returns the new invite link as `String` on success.
    def export_chat_invite_link(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("exportChatInviteLink", {
        chat_id: chat_id,
      })

      response.to_s
    end

    # Use this method to set a new profile photo for the chat. Photos can't be changed
    # for private chats. The bot must be an administrator in the chat for this to
    # work and must have the appropriate admin rights.
    # Returns `true` on success.
    #
    # > **Note:** In regular groups (non-supergroups), this method will only work if the
    # > `All Members Are Admins` setting is off in the target group.
    def set_chat_photo(chat, photo)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("setChatPhoto", {
        chat_id: chat_id,
        photo:   photo,
      })

      response == "true"
    end

    # Use this method to delete a chat photo. Photos can't be changed for private chats.
    # The bot must be an administrator in the chat for this to work and must have the
    # appropriate admin rights.
    # Returns `true` on success.
    #
    # > **Note:** In regular groups (non-supergroups), this method will only work if the
    # `All Members Are Admins` setting is off in the target group.
    def delete_chat_photo(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("deleteChatPhoto", {
        chat_id: chat_id,
      })

      response == "true"
    end

    # Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
    # Returns True on success.
    def set_chat_admininstrator_custom_title(chat, user, custom_title)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      user_id = user.is_a?(Int) ? user : user.id

      response = request("setChatAdministratorCustomTitle", {
        chat_id:      chat_id,
        user_id:      user_id,
        custom_title: custom_title,
      })

      response == true
    end

    # Use this method to set default chat permissions for all members. The bot must be
    # an administrator in the group or a supergroup for this to work and must have
    # the can_restrict_members admin rights.
    # Returns True on success.
    def set_chat_permissions(chat, permissions)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("setChatPermissions", {
        chat_id:     chat_id,
        permissions: permissions.to_json,
      })

      response == "true"
    end

    # Use this method to change the title of a chat. Titles can't be changed for
    # private chats. The bot must be an administrator in the chat for this to
    # work and must have the appropriate admin rights.
    # Returns `true` on success.
    #
    # > **Note:** In regular groups (non-supergroups), this method will only
    # > work if the `All Members Are Admins` setting is off in the target group.
    def set_chat_title(chat, title)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("setchatTitle", {
        chat_id: chat_id,
        title:   title,
      })

      response == "true"
    end

    # Use this method to change the description of a supergroup or a channel.
    # The bot must be an administrator in the chat for this to work and
    # must have the appropriate admin rights.
    # Returns `true` on success.
    def set_chat_description(chat, description)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("setchatDescription", {
        chat_id:     chat_id,
        description: description,
      })

      response == "true"
    end

    # Use this method to pin a message in a group, a supergroup, or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the `can_pin_messages` admin right in the supergroup or
    # `can_edit_messages` admin right in the channel.
    # Returns `true` on success.
    def pin_chat_message(chat, message, disable_notification = false)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int) ? message : message.id

      response = request("pinChatMessage", {
        chat_id:              chat_id,
        message_id:           message_id,
        disable_notification: disable_notification,
      })

      response == "true"
    end

    # Use this method to unpin a message in a group, a supergroup, or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the ‘can_pin_messages’ admin right in the supergroup or
    # ‘can_edit_messages’ admin right in the channel.
    # Returns `true` on success.
    def unpin_chat_message(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("unpinChatMessage", {
        chat_id: chat_id,
      })

      response == "true"
    end

    # Use this method for your bot to leave a group,
    # supergroup, or channel.
    # Returns `true` on success.
    def leave_chat(chat)
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("leaveChat", {
        chat_id: chat_id,
      })

      Chat.from_json(response)
    end

    # Use this method to send audio files, if you want Telegram clients to display
    # them in the music player. Your audio must be in the `.mp3` format.
    # On success, the sent `Message` is returned. Bots can currently
    # send audio files of up to **50 MB** in size, this limit may be
    # changed in the future.
    #
    # For sending voice messages, use the `#sendVoice` method instead.
    # TODO: Add filesize checking and validation.
    def send_audio(
      chat,
      audio,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendAudio", {
        chat_id:              chat_id,
        audio:                audio,
        caption:              caption,
        duration:             duration,
        preformer:            preformer,
        title:                title,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    def send_animation(
      chat,
      animation,
      duration = nil,
      width = nil,
      height = nil,
      thumb = nil,
      caption = nil,
      parse_mode = ParseMode::Normal,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendAnimation", {
        chat_id:              chat_id,
        animation:            animation,
        duration:             duration,
        width:                width,
        height:               height,
        thumb:                thumb,
        caption:              caption,
        parse_mode:           parse_mode,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method when you need to tell the user that something is happening on the
    # bot's side. The status is set for 5 seconds or less (when a message arrives
    # from your bot, Telegram clients clear its typing status).
    # Returns `true` on success.
    #
    # > Example: The ImageBot needs some time to process a request and upload the image.
    # > Instead of sending a text message along the lines of “Retrieving image, please
    # > wait…”, the bot may use `#sendChatAction` with action = upload_photo. The user
    # > will see a “sending photo” status for the bot.
    #
    # We only recommend using this method when a response from the bot will take a
    # noticeable amount of time to arrive.
    def send_chat_action(
      chat,
      action : ChatAction
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id

      response = request("sendChatAction", {
        chat_id: chat_id,
        action:  action.to_s,
      })

      response == "true"
    end

    # Use this method to send phone contacts.
    # On success, the sent `Message` is returned.
    def send_contact(
      chat,
      phone_number,
      first_name,
      last_name = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendContact", {
        chat_id:              chat_id,
        phone_number:         phone_number,
        first_name:           first_name,
        last_name:            last_name,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send a dice, which will have a random value from 1 to 6.
    # On success, the sent Message is returned.
    def send_dice(
      chat,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendDice", {
        chat_id: chat_id,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup
      })

      Message.from_json(response)
    end

    # Use this method to send general files.
    # On success, the sent `Message` is returned. Bots can currently send files
    # of any type of up to **50 MB** in size, this limit
    # may be changed in the future.
    # TODO: Add filesize checking and validation.
    def send_document(
      chat,
      document,
      caption = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      document = check_open_local_file(document)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendDocument", {
        chat_id:              chat_id,
        document:             document,
        caption:              caption,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send point on the map.
    # On success, the sent `Message` is returned.
    def send_location(
      chat,
      latitude,
      longitude,
      live_period = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendLocation", {
        chat_id:              chat_id,
        latitude:             latitude,
        longitude:            longitude,
        live_period:          live_period,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send text messages.
    # On success, the sent `Message` is returned.
    def send_message(
      chat,
      text,
      parse_mode = ParseMode::Normal,
      link_preview = false,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendMessage", {
        chat_id:                  chat_id,
        text:                     text,
        parse_mode:               parse_mode,
        disable_web_page_preview: !link_preview,
        disable_notification:     disable_notification,
        reply_to_message_id:      reply_to_message_id,
        reply_markup:             reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send photos.
    # On success, the sent `Message` is returned.
    def send_photo(
      chat,
      photo,
      caption = nil,
      parse_mode = ParseMode::Normal,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      photo = check_open_local_file(photo)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s
      reply_to_message_id = reply_to_message.is_a?(Int) || reply_to_message.nil? ? reply_to_message : reply_to_message.id

      response = request("sendPhoto", {
        chat_id:              chat_id,
        photo:                photo,
        caption:              caption,
        parse_mode:           parse_mode,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    def edit_message_media(
      chat,
      media,
      message = nil,
      inline_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      media = check_open_local_file(media)
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id
      inline_message_id = inline_message.is_a?(Int32 | Int64 | Nil) ? inline_message : inline_message.id

      if !message_id && !inline_message_id
        raise "Either a message or inline_message is required"
      end

      response = request("editMessageMedia", {
        chat_id:           chat_id,
        media:             media,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup,
      })

      Message.from_json(response)
    end

    # Use this method to send a group of photos or videos as an album.
    # On success, an array of the sent `Messages` is returned.
    def send_media_group(
      chat,
      media : Array(InputMediaPhoto | InputMediaVideo),
      disable_notification = false,
      reply_to_message = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendMediaGroup", {
        chat_id:              chat_id,
        media:                media,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
      })

      Array(Message).from_json(response)
    end

    # Use this method to send information about a venue.
    # On success, the sent `Message` is returned.
    def send_venue(
      chat,
      latitude,
      longitude,
      title,
      address,
      foursquare_id = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendVenue", {
        chat_id:              chat_id,
        latitude:             latitude,
        longitude:            longitude,
        title:                title,
        address:              address,
        foursquare_id:        foursquare_id,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send video files, Telegram clients support mp4 videos
    # (other formats may be sent as Document).
    # On success, the sent `Message` is returned. Bots can currently send
    # video files of up to **50 MB** in size, this limit may be
    # changed in the future.
    # TODO: Add filesize checking and validation.
    def send_video(
      chat,
      video,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      video = check_open_local_file(video)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendVideo", {
        chat_id:              chat_id,
        video:                video,
        duration:             duration,
        width:                width,
        height:               height,
        caption:              caption,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # As of [v.4.0](https://telegram.org/blog/video-messages-and-telescope), Telegram
    # clients support rounded square `mp4` videos of up to **1** minute long.
    # Use this method to send video messages.
    # On success, the sent `Message` is returned.
    def send_video_note(
      chat,
      video_note,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      video_note = check_open_local_file(video_note)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendVideoNote", {
        chat_id:              chat_id,
        video_note:           video_note,
        duration:             duration,
        width:                width,
        height:               height,
        caption:              caption,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to send audio files, if you want Telegram clients to display the
    # file as a playable voice message. For this to work, your audio must be in
    # an `.ogg` file encoded with OPUS (other formats may be sent as `Audio`
    # or `Document`).
    # On success, the sent `Message` is returned. Bots can currently send voice
    # messages of up to **50 MB** in size, this limit may be changed in the future.
    # TODO: Add filesize checking and validation.
    def send_voice(
      chat,
      voice,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      voice = check_open_local_file(voice)
      chat_id = chat.is_a?(Int) ? chat : chat.id
      reply_to_message_id = reply_to_message.is_a?(Int32 | Int64 | Nil) ? reply_to_message : reply_to_message.id

      response = request("sendVoice", {
        chat_id:              chat_id,
        voice:                voice,
        caption:              caption,
        duration:             duration,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to edit live location messages. A location can be edited until
    # its live_period expires or editing is explicitly disabled by a call to
    # `#stopMessageLiveLocation`.
    # On success, if the edited message wasn't by the bot, the edited `Message` is
    # returned, otherwise `true` is returned.
    def edit_message_live_location(
      chat,
      latitude,
      longitude,
      message = nil,
      inline_message = nil,
      reply_markup = nil
    )
      if !message && !inline_message
        raise "A message_id or inline_message_id is required"
      end

      chat_id = chat.is_a?(Int) ? chat : chat.id
      message_id = message.is_a?(Int32 | Int64 | Nil) ? message : message.id
      inline_message_id = inline_message.is_a?(Int32 | Int64 | Nil) ? inline_message : inline_message.id

      response = request("editMessageLiveLocation", {
        chat_id:           chat_id,
        latitude:          latitude,
        longitude:         longitude,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      if message == "true" || message == "false"
        return message == "true"
      end

      Message.from_json(response)
    end

    # Use this method to stop updating a live location message before
    # live_period expires.
    # On success, if the message was sent by the bot, the sent
    # `Message` is returned, otherwise `true` is returned.
    def stop_message_live_location(
      chat,
      message = nil,
      inline_message = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      chat_id = object_or_id(chat)
      message_id = object_or_id(message)
      inline_message_id = object_or_id(inline_message)

      response = request("stopMessageLiveLocation", {
        chat_id:           chat_id,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to change the list of the bot's commands.
    # Returns `true` on success.
    def set_my_commands(
      commands : Array(BotCommand | NamedTuple(command: String, description: String))
    )
      # commands = commands.map(&.to_h.transform_keys(&.to_s))

      response = request("setMyCommands", {
        commands: commands
      })

      response == "true"
    end

    # Use this method to get the current list of the bot's commands. Requires no parameters.
    # Returns Array of BotCommand on success.
    def get_my_commands
      response = request("getMyCommands")
      Array(BotCommand).from_json(response)
    end

    ##########################
    #        POLLING         #
    ##########################

    # Start polling for updates. This method uses a combination of `#get_updates`
    # and `#handle_update` to send continuously check Telegram's servers
    # for updates.
    def poll
      unset_webhook
      @polling = true

      Log.info { "Polling for updates" }
      while @polling
        begin
          updates = get_updates
          updates.each do |u|
            handle_update(u)
          end
        rescue exception
          Log.error { exception.message.to_s }
        end
      end
    end

    # Stops the bot from polling.
    def stop_polling
      @polling = false
    end
  end
end
