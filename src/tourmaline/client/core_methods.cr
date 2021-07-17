require "uri"

module Tourmaline
  class Client
    module CoreMethods
      include Logger

      getter polling : Bool = false
      getter next_offset : Int64 = 0.to_i64

      # Instance variable that points to the internal webhook server
      # Should not be used outside of this class
      @webhook_server : HTTP::Server?

      # Convenience method to check if this bot is an admin in
      # the current chat. See `Client#get_chat_administrators`
      # for more info.
      #
      # Note: This method should be used sparingly. It's much better to cache admins.
      def is_admin?(chat_id)
        admins = get_chat_administrators(chat_id)
        admins.any? { |a| a.user.id = @bot_info.id }
      end

      # A simple method for testing your bot's auth token. Requires
      # no parameters. Returns basic information about the bot
      # in form of a `User` object.
      def get_me
        request(User, "getMe")
      end

      # Use this method to log out from the cloud Bot API server before launching the bot locally.
      # You must log out the bot before running it locally, otherwise there is no guarantee that
      # the bot will receive updates. After a successful call, you can immediately log in on a
      # local server, but will not be able to log in back to the cloud Bot API server for
      # 10 minutes.
      #
      # Returns `true` on success. Requires no parameters.
      def log_out
        request("logOut")
      end

      # Use this method to close the bot instance before moving it from one local server to another.
      # You need to delete the webhook before calling this method to ensure that the bot isn't
      # launched again after server restart. The method will return error 429 in the first 10
      # minutes after the bot is launched.
      #
      # Returns `true` on success. Requires no parameters.
      def close
        request("close")
      end

      # Use this method to receive incoming updates using long polling
      # ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)).
      # An `Array` of `Update` objects is returned.
      def get_updates(
        offset = @next_offset,
        limit = 100,
        timeout = 0,
        allowed_updates = [] of String
      )
        updates = request(Array(Update), "getUpdates", {
          offset:          offset,
          limit:           limit,
          timeout:         timeout,
          allowed_updates: allowed_updates,
        })

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
      # !!! note
      #     Alternatively, the user can be redirected to the specified
      #     Game URL (`url`). For this option to work, you must first
      #     create a game for your bot via @Botfather and accept the
      #     terms. Otherwise, you may use links like
      #     [t.me/your_bot?start=XXXX](https://t.me/your_bot?start=XXXX)
      #     that open your bot with a parameter.
      def answer_callback_query(
        callback_query_id,
        text = nil,
        show_alert = nil,
        url = nil,
        cache_time = nil
      )
        request(Bool, "answerCallbackQuery", {
          callback_query_id: callback_query_id,
          text:              text,
          show_alert:        show_alert,
          url:               url,
          cache_time:        cache_time,
        })
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
        request(Bool, "answerInlineQuery", {
          inline_query_id:     inline_query_id,
          results:             results.to_json,
          cache_time:          cache_time,
          is_personal:         is_personal,
          next_offset:         next_offset,
          switch_pm_text:      switch_pm_text,
          switch_pm_parameter: switch_pm_parameter,
        })
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
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id

        request(Bool, "deleteMessage", {
          chat_id:    chat_id,
          message_id: message_id,
        })
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
        parse_mode = @default_parse_mode,
        caption_entities = [] of MessageEntity,
        reply_markup = nil
      )
        if !message && !inline_message
          raise "A message_id or inline_message_id is required"
        end

        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        inline_message_id = inline_message.is_a?(Int::Primitive | Nil) ? inline_message : inline_message.id

        request(Bool | Message, "editMessageCaption", {
          chat_id:           chat_id,
          caption:           caption,
          message_id:        message_id,
          inline_message_id: inline_message_id,
          parse_mode:        parse_mode,
          caption_entities:  caption_entities,
          reply_markup:      reply_markup ? reply_markup.to_json : nil,
        })
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

        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        inline_message_id = inline_message.is_a?(Int::Primitive | Nil) ? inline_message : inline_message.id

        request(Bool | Message, "editMessageReplyMarkup", {
          chat_id:           chat_id,
          message_id:        message_id,
          inline_message_id: inline_message_id,
          reply_markup:      reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to edit text and game messages.
      # On success, if the edited message is not an inline message,
      # the edited Message is returned, otherwise true is returned.
      def edit_message_text(
        text,
        chat = nil,
        message = nil,
        inline_message = nil,
        parse_mode = @default_parse_mode,
        entities = [] of MessageEntity,
        disable_link_preview = false,
        reply_markup = nil
      )
        if (!message || !chat) && !inline_message
          raise "edit_message_text requires either a chat and a message, or an inline_message"
        end

        if !inline_message
          chat_id = chat.is_a?(Int::Primitive | String | Nil) ? chat : chat.id
          message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        else
          inline_message_id = inline_message.is_a?(String | Int::Primitive) ? inline_message : inline_message.id
        end

        request(Message | Bool, "editMessageText", {
          chat_id:                  chat_id,
          message_id:               message_id,
          inline_message_id:        inline_message_id,
          text:                     text,
          parse_mode:               parse_mode,
          entities:                 entities,
          disable_web_page_preview: disable_link_preview,
          reply_markup:             reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to forward messages of any kind. On success,
      # the sent `Message` is returned.
      def forward_message(
        chat,
        from_chat,
        message,
        disable_notification = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int) ? message : message.id
        from_chat_id = from_chat.is_a?(Int) ? from_chat : from_chat.id

        request(Message, "forwardMessage", {
          chat_id:              chat_id,
          from_chat_id:         from_chat_id,
          message_id:           message_id,
          disable_notification: disable_notification,
        })
      end

      # Use this method to get up to date information about the chat
      # (current name of the user for one-on-one conversations,
      # current username of a user, group or channel, etc.).
      # Returns a `Chat` object on success.
      #
      # !!! tip
      #     When using TDLight this method isn't restructed to chats/users your
      #     bot is familiar with.
      #
      # !!! warning
      #     When using TDLight this method will first check for a locally cached
      #     chat, then use MTProto if that fails. When using MTProto this method
      #     is __heavily__ rate limited, so be careful.
      def get_chat(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Chat, "getChat", {
          chat_id: chat_id,
        })
      end

      # Use this method to get a list of administrators in a chat. On success,
      # returns an `Array` of `ChatMember` objects that contains information
      # about all chat administrators except other bots. If the chat is a
      # group or a supergroup and no administrators were appointed,
      # only the creator will be returned.
      def get_chat_administrators(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Array(ChatMember), "getChatAdministrators", {
          chat_id: chat_id,
        })
      end

      # Use this method to get information about a member of a chat. Returns a
      # `ChatMember` object on success.
      def get_chat_member(chat, user)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        chat_member = request(ChatMember, "getChatMember", {
          chat_id: chat_id,
          user_id: user_id,
        })

        chat_member.chat_id = chat_id
        chat_member
      end

      # Use this method to get the number of members in a chat.
      # Returns `Int32` on success.
      def get_chat_members_count(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Int32, "getChatMembersCount", {
          chat_id: chat_id,
        })
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
        request(TFile, "getFile", {
          file_id: file_id,
        })
      end

      # Takes a file id and returns a link to download the file. The link will be valid
      # for at least one hour.
      def get_file_link(file_id)
        file = get_file(file_id)
        token = @bot_token ? "bot#{@bot_token}" : "user#{@user_token}"
        File.join(@endpoint, "file", token, file.file_path.to_s)
      end

      # Given a file_id, download the file and return its path on the file system.
      def download_file(file_id, path = nil)
        path = path ? path : File.tempname
        res = HTTP::Client.get(get_file_link(file_id))
        if res.status_code < 300
          File.write(path, res.body)
          path
        else
          result = JSON.parse(res.body)
          raise Error.from_message(result["description"].as_s)
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

        request(UserProfilePhotos, "getUserProfilePhotos", {
          user_id: user_id,
          offset:  offset,
          limit:   limit,
        })
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
        until_date = nil,
        revoke_messages = nil,
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id
        until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)

        request(Bool, "kickChatMember", {
          chat_id:    chat_id,
          user_id:    user_id,
          until_date: until_date,
          revoke_messages: revoke_messages,
        })
      end

      # Use this method to unban a previously kicked user in a supergroup
      # or channel. The user will not return to the group or channel
      # automatically, but will be able to join via link, etc.
      # The bot must be an administrator for this to work.
      # Returns `true` on success.
      def unban_chat_member(
        chat,
        user,
        only_if_banned = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "unbanChatMember", {
          chat_id:        chat_id,
          user_id:        user_id,
          only_if_banned: only_if_banned,
        })
      end

      # Use this method to easily mute a user in a supergroup. The bot must
      # be an administrator in the supergroup for this to work and must
      # have the appropriate admin right. Works by calling
      # `restrict_chat_member` with all permissions
      # set to `false`.
      # Returns `true` on success.
      def mute_chat_member(chat, user, until_date = nil)
        permissions = ChatPermissions.new(
          can_send_messages: false,
          can_send_media_messages: false,
          can_send_polls: false,
          can_send_other_messages: false,
          can_add_web_page_previews: false,
          can_change_info: false,
          can_invite_users: false,
          can_pin_messages: false
        )

        restrict_chat_member(chat, user, permissions, until_date)
      end

      # Use this method to restrict a user in a supergroup. The bot must be an
      # administrator in the supergroup for this to work and must have the
      # appropriate admin rights. Pass True for all permissions to
      # lift restrictions from a user.
      # Returns `true` on success.
      def restrict_chat_member(
        chat,
        user,
        permissions,
        until_date = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id
        until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)
        permissions = permissions.is_a?(NamedTuple) ? ChatPermissions.new(**permissions) : permissions

        request(Bool, "restrictChatMember", {
          chat_id:     chat_id,
          user_id:     user_id,
          until_date:  until_date,
          permissions: permissions.to_json,
        })
      end

      # Use this method to promote or demote a user in a supergroup or a channel.
      # The bot must be an administrator in the chat for this to work and must
      # have the appropriate admin rights. Pass False for all boolean
      # parameters to demote a user.
      # Returns `true` on success.
      def promote_chat_member(
        chat,
        user,
        is_anonymous = false,
        until_date = nil,
        can_manage_chat = nil,
        can_change_info = nil,
        can_post_messages = nil,
        can_edit_messages = nil,
        can_delete_messages = nil,
        can_invite_users = nil,
        can_manage_voice_chats = nil,
        can_restrict_members = nil,
        can_pin_messages = nil,
        can_promote_members = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "promoteChatMember", {
          chat_id:              chat_id,
          user_id:              user_id,
          is_anonymous:         is_anonymous,
          until_date:           until_date,
          can_manage_chat:      can_manage_chat,
          can_change_info:      can_change_info,
          can_post_messages:    can_post_messages,
          can_edit_messages:    can_edit_messages,
          can_delete_messages:  can_delete_messages,
          can_invite_users:     can_invite_users,
          can_manage_voice_chats: can_manage_voice_chats,
          can_restrict_members: can_restrict_members,
          can_pin_messages:     can_pin_messages,
          can_promote_members:  can_promote_members,
        })
      end

      # Use this method to generate a new invite link for a chat; any previously
      # generated link is revoked. The bot must be an administrator in the chat
      # for this to work and must have the appropriate admin rights.
      # Returns the new invite link as `String` on success.
      def export_chat_invite_link(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(String, "exportChatInviteLink", {
          chat_id: chat_id,
        })
      end

      # Use this method to set a new profile photo for the chat. Photos can't be changed
      # for private chats. The bot must be an administrator in the chat for this to
      # work and must have the appropriate admin rights.
      # Returns `true` on success.
      #
      # > **Note:** In regular groups (non-supergroups), this method will only work if the
      # > `All Members Are Admins` setting is off in the target group.
      def set_chat_photo(chat, photo)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "setChatPhoto", {
          chat_id: chat_id,
          photo:   photo,
        })
      end

      # Use this method to delete a chat photo. Photos can't be changed for private chats.
      # The bot must be an administrator in the chat for this to work and must have the
      # appropriate admin rights.
      # Returns `true` on success.
      #
      # > **Note:** In regular groups (non-supergroups), this method will only work if the
      # `All Members Are Admins` setting is off in the target group.
      def delete_chat_photo(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "deleteChatPhoto", {
          chat_id: chat_id,
        })
      end

      # Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
      # Returns True on success.
      def set_chat_admininstrator_custom_title(chat, user, custom_title)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "setChatAdministratorCustomTitle", {
          chat_id:      chat_id,
          user_id:      user_id,
          custom_title: custom_title,
        })
      end

      # Use this method to set default chat permissions for all members. The bot must be
      # an administrator in the group or a supergroup for this to work and must have
      # the can_restrict_members admin rights.
      # Returns True on success.
      def set_chat_permissions(chat, permissions)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "setChatPermissions", {
          chat_id:     chat_id,
          permissions: permissions.to_json,
        })
      end

      # Use this method to change the title of a chat. Titles can't be changed for
      # private chats. The bot must be an administrator in the chat for this to
      # work and must have the appropriate admin rights.
      # Returns `true` on success.
      #
      # > **Note:** In regular groups (non-supergroups), this method will only
      # > work if the `All Members Are Admins` setting is off in the target group.
      def set_chat_title(chat, title)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "setchatTitle", {
          chat_id: chat_id,
          title:   title,
        })
      end

      # Use this method to change the description of a supergroup or a channel.
      # The bot must be an administrator in the chat for this to work and
      # must have the appropriate admin rights.
      # Returns `true` on success.
      def set_chat_description(chat, description)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "setchatDescription", {
          chat_id:     chat_id,
          description: description,
        })
      end

      # Use this method to pin a message in a group, a supergroup, or a channel.
      # The bot must be an administrator in the chat for this to work and must
      # have the `can_pin_messages` admin right in the supergroup or
      # `can_edit_messages` admin right in the channel.
      # Returns `true` on success.
      def pin_chat_message(chat, message, disable_notification = false)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int) ? message : message.id

        request(Bool, "pinChatMessage", {
          chat_id:              chat_id,
          message_id:           message_id,
          disable_notification: disable_notification,
        })
      end

      # Use this method to unpin a message in a group, a supergroup, or a channel.
      # The bot must be an administrator in the chat for this to work and must
      # have the ‘can_pin_messages’ admin right in the supergroup or
      # ‘can_edit_messages’ admin right in the channel.
      # Returns `true` on success.
      def unpin_chat_message(chat, message = nil)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id

        request(Bool, "unpinChatMessage", {
          chat_id:    chat_id,
          message_id: message_id,
        })
      end

      def unpin_all_chat_messages(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "unpinAllChatMessages", {
          chat_id: chat_id,
        })
      end

      # Use this method for your bot to leave a group,
      # supergroup, or channel.
      # Returns `true` on success.
      def leave_chat(chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "leaveChat", {
          chat_id: chat_id,
        })
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
        caption_entities = [] of MessageEntity,
        duration = nil,
        preformer = nil,
        title = nil,
        parse_mode = @default_parse_mode,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendAudio", {
          chat_id:                     chat_id,
          audio:                       audio,
          caption:                     caption,
          caption_entities:            caption_entities,
          duration:                    duration,
          preformer:                   preformer,
          title:                       title,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      def send_animation(
        chat,
        animation,
        duration = nil,
        width = nil,
        height = nil,
        thumb = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = @default_parse_mode,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendAnimation", {
          chat_id:                     chat_id,
          animation:                   animation,
          duration:                    duration,
          width:                       width,
          height:                      height,
          thumb:                       thumb,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
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
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "sendChatAction", {
          chat_id: chat_id,
          action:  action.to_s,
        })
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
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendContact", {
          chat_id:                     chat_id,
          phone_number:                phone_number,
          first_name:                  first_name,
          last_name:                   last_name,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      {% for val in [{"dice", "🎲", 6}, {"dart", "🎯", 6}, {"basketball", "🏀", 6}, {"football", "⚽️", 5}, {"soccerball", "⚽️", 5}, {"slot_machine", "🎰", 64}, {"bowling", "🎳", 6}] %}
      # Use this method to send a {{ val[0].id }} ({{ val[1].id }} emoji), which will have a random value from 1 to {{ val[2].id }}.
      # On success, the sent Message is returned.
      def send_{{ val[0].id }}(
        chat,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendDice", {
          chat_id:              chat_id,
          emoji:                {{ val[1] }},
          disable_notification: disable_notification,
          reply_to_message_id:  reply_to_message_id,
          allow_sending_without_reply:         allow_sending_without_reply,
          reply_markup:         reply_markup,
        })
      end
      {% end %}

      # Use this method to send general files.
      # On success, the sent `Message` is returned. Bots can currently send files
      # of any type of up to **50 MB** in size, this limit
      # may be changed in the future.
      # TODO: Add filesize checking and validation.
      def send_document(
        chat,
        document,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = @default_parse_mode,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        document = check_open_local_file(document)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendDocument", {
          chat_id:                     chat_id,
          document:                    document,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to send point on the map.
      # On success, the sent `Message` is returned.
      def send_location(
        chat,
        latitude,
        longitude,
        horizontal_accuracy = nil,
        live_period = nil,
        proximity_alert_radius = nil,
        heading = nil,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendLocation", {
          chat_id:                     chat_id,
          latitude:                    latitude,
          longitude:                   longitude,
          horizontal_accuracy:         horizontal_accuracy,
          live_period:                 live_period,
          heading:                     heading,
          proximity_alert_radius:      proximity_alert_radius,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to send text messages.
      # On success, the sent `Message` is returned.
      def send_message(
        chat,
        text,
        parse_mode = @default_parse_mode,
        entities = [] of MessageEntity,
        link_preview = false,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Message, "sendMessage", {
          chat_id:                     chat_id,
          text:                        text,
          parse_mode:                  parse_mode,
          entities:                    entities,
          disable_web_page_preview:    !link_preview,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      def copy_message(
        chat,
        from_chat,
        message,
        caption = nil,
        parse_mode = @default_parse_mode,
        caption_entities = [] of MessageEntity,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        from_chat_id = from_chat.is_a?(Int::Primitive | String) ? from_chat : from_chat.id
        message_id = message.is_a?(Int::Primitive) ? message : message.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request("copyMessage", {
          chat_id:                     chat_id,
          from_chat_id:                from_chat_id,
          message_id:                  message_id,
          caption:                     caption,
          parse_mode:                  parse_mode,
          caption_entities:            caption_entities,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to send photos.
      # On success, the sent `Message` is returned.
      def send_photo(
        chat,
        photo,
        caption = nil,
        parse_mode = @default_parse_mode,
        caption_entities = [] of MessageEntity,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        photo = check_open_local_file(photo)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int) || reply_to_message.nil? ? reply_to_message : reply_to_message.id

        request(Message, "sendPhoto", {
          chat_id:                     chat_id,
          photo:                       photo,
          caption:                     caption,
          parse_mode:                  parse_mode,
          caption_entities:            caption_entities,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      def edit_message_media(
        chat,
        media,
        message = nil,
        inline_message = nil,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        media = check_open_local_file(media)
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        inline_message_id = inline_message.is_a?(Int::Primitive | Nil) ? inline_message : inline_message.id

        if !message_id && !inline_message_id
          raise "Either a message or inline_message is required"
        end

        request(Message, "editMessageMedia", {
          chat_id:           chat_id,
          media:             media,
          message_id:        message_id,
          inline_message_id: inline_message_id,
          reply_markup:      reply_markup,
        })
      end

      # Use this method to send a group of photos or videos as an album.
      # On success, an array of the sent `Messages` is returned.
      def send_media_group(
        chat,
        media : Array(InputMediaPhoto | InputMediaVideo | InputMediaAudio | InputMediaDocument),
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Array(Message), "sendMediaGroup", {
          chat_id:                     chat_id,
          media:                       media,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
        })
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
        foursquare_type = nil,
        google_place_id = nil,
        google_place_type = nil,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendVenue", {
          chat_id:                     chat_id,
          latitude:                    latitude,
          longitude:                   longitude,
          title:                       title,
          address:                     address,
          foursquare_id:               foursquare_id,
          foursquare_type:             foursquare_type,
          google_place_id:             google_place_id,
          google_place_type:           google_place_type,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
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
        caption_entities = [] of MessageEntity,
        parse_mode = @default_parse_mode,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        video = check_open_local_file(video)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendVideo", {
          chat_id:                     chat_id,
          video:                       video,
          duration:                    duration,
          width:                       width,
          height:                      height,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
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
        caption_entities = [] of MessageEntity,
        parse_mode = @default_parse_mode,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        video_note = check_open_local_file(video_note)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendVideoNote", {
          chat_id:                     chat_id,
          video_note:                  video_note,
          duration:                    duration,
          width:                       width,
          height:                      height,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
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
        caption_entities = [] of MessageEntity,
        duration = nil,
        preformer = nil,
        title = nil,
        disable_notification = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        voice = check_open_local_file(voice)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.id

        request(Message, "sendVoice", {
          chat_id:                     chat_id,
          voice:                       voice,
          caption:                     caption,
          caption_entities:            caption_entities,
          duration:                    duration,
          disable_notification:        disable_notification,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to edit live location messages. A location can be edited until
      # its live_period expires or editing is explicitly disabled by a call to
      # `#stopMessageLiveLocation`.
      #
      # On success, if the edited message wasn't by the bot, the edited `Message` is
      # returned, otherwise `true` is returned.
      def edit_message_live_location(
        chat,
        latitude,
        longitude,
        horizontal_accuracy = nil,
        live_period = nil,
        proximity_alert_radius = nil,
        heading = nil,
        message = nil,
        inline_message = nil,
        reply_markup = nil
      )
        if !message && !inline_message
          raise "A message_id or inline_message_id is required"
        end

        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        inline_message_id = inline_message.is_a?(Int::Primitive | Nil) ? inline_message : inline_message.id

        request(Bool | Message, "editMessageLiveLocation", {
          chat_id:                chat_id,
          latitude:               latitude,
          longitude:              longitude,
          horizontal_accuracy:    horizontal_accuracy,
          live_period:            live_period,
          proximity_alert_radius: proximity_alert_radius,
          heading:                heading,
          message_id:             message_id,
          inline_message_id:      inline_message_id,
          reply_markup:           reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to stop updating a live location message before
      # live_period expires.
      #
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

        request(Bool | Message, "stopMessageLiveLocation", {
          chat_id:           chat_id,
          message_id:        message_id,
          inline_message_id: inline_message_id,
          reply_markup:      reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to change the list of the bot's commands.
      # Returns `true` on success.
      def set_my_commands(
        commands : Array(BotCommand | NamedTuple(command: String, description: String)),
        scope : BotCommandScope? = nil,
        language_code : String? = nil,
      )
        # commands = commands.map(&.to_h.transform_keys(&.to_s))

        request(Bool, "setMyCommands", {
          commands: commands,
          scope: scope,
          language_code: language_code,
        })
      end

      # Use this method to get the current list of the bot's commands. Requires no parameters.
      # Returns Array of BotCommand on success.
      def get_my_commands(scope : BotCommandScope? = nil, language_code : String? = nil)
        request(Array(BotCommand), "getMyCommands", {
          scope: scope,
          language_code: language_code,
        })
      end

      # Use this method to delete the list of the bot's commands for the given scope and user language.
      # After deletion, higher level commands will be shown to affected users.
      # Returns True on success.
      def delete_my_commands(scope : BotCommandScope? = nil, language_code : String? = nil)
        request(Bool, "deleteMyCommands", {
          scope: scope,
          language_code: language_code,
        })
      end

      ##########################
      #        POLLING         #
      ##########################

      # Start polling for updates. This method uses a combination of `#get_updates`
      # and `#handle_update` to send continuously check Telegram's servers
      # for updates.
      def poll(delete_webhook = false)
        self.delete_webhook if delete_webhook
        @polling = true

        Log.info { "Polling for updates" }

        while @polling
          begin
            updates = get_updates
            updates.each do |u|
              handle_update(u)
            end
          rescue ex : Error::PoolRetryAttemptsExceeded
            raise ex
          rescue ex
            Log.error(exception: ex) { "Error during polling" }
          end
        end
      end

      # Stops the bot from polling.
      def stop_polling
        Log.info { "Stopping polling" }
        @polling = false
      end
    end
  end
end
