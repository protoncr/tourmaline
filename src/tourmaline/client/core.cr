require "uri"

module Tourmaline
  class Client
    module CoreMethods
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
        request(Tourmaline::Model::User, "getMe")
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
        updates = request(Array(Tourmaline::Model::Update), "getUpdates", {
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
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.message_id

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
        parse_mode = Tourmaline::Client.default_parse_mode,
        caption_entities = [] of MessageEntity,
        reply_markup = nil
      )
        if !message && !inline_message
          raise "A message_id or inline_message_id is required"
        end

        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int::Primitive | Nil) ? message : message.id
        inline_message_id = inline_message.is_a?(Int::Primitive | Nil) ? inline_message : inline_message.id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Bool | Tourmaline::Model::Message, "editMessageCaption", {
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

        request(Bool | Tourmaline::Model::Message, "editMessageReplyMarkup", {
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
        parse_mode = Tourmaline::Client.default_parse_mode,
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

        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message | Bool, "editMessageText", {
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
        message_thread_id = nil,
        disable_notification = false,
        protect_content = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        message_id = message.is_a?(Int) ? message : message.id
        from_chat_id = from_chat.is_a?(Int) ? from_chat : from_chat.id

        request(Tourmaline::Model::Message, "forwardMessage", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          from_chat_id:         from_chat_id,
          message_id:           message_id,
          disable_notification: disable_notification,
          protect_content:      protect_content,
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

        request(Tourmaline::Model::Chat, "getChat", {
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

        request(Array(Tourmaline::Model::ChatMember), "getChatAdministrators", {
          chat_id: chat_id,
        })
      end

      # Use this method to get information about a member of a chat. Returns a
      # `ChatMember` object on success.
      def get_chat_member(chat, user)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        chat_member = request(Tourmaline::Model::ChatMember, "getChatMember", {
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

      # Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user.
      # Requires no parameters.
      # Returns an Array of Sticker objects.
      def get_forum_topic_icon_stickers
        request(Array(Tourmaline::Model::Sticker), "getForumTopicIconStickers")
      end

      # Use this method to create a topic in a forum supergroup chat. The bot must be an administrator
      # in the chat for this to work and must have the can_manage_topics administrator rights.
      # Returns information about the created topic as a ForumTopic object.
      def create_forum_topic(
        chat,
        name,
        icon_color = nil,
        icon_custom_emoji_id = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Tourmaline::Model::ForumTopic, "createForumTopic", {
          chat_id:              chat_id,
          name:                 name,
          icon_color:           icon_color,
          icon_custom_emoji_id: icon_custom_emoji_id,
        })
      end

      # Use this method to edit name and icon of a topic in a forum supergroup chat. The bot
      # must be an administrator in the chat for this to work and must have
      # can_manage_topics administrator rights, unless it is the
      # creator of the topic.
      # Returns True on success.
      def edit_forum_topic(
        chat,
        message_thread_id,
        name,
        icon_custom_emoji_id
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "editForumTopic", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          name:                 name,
          icon_custom_emoji_id: icon_custom_emoji_id,
        })
      end

      # Use this method to close an open topic in a forum supergroup chat. The bot must be
      # an administrator in the chat for this to work and must have the can_manage_topics
      # administrator rights, unless it is the creator of the topic.
      # Returns True on success.
      def close_forum_topic(
        chat,
        message_thread_id
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "closeForumTopic", {
          chat_id:           chat_id,
          message_thread_id: message_thread_id,
        })
      end

      # Use this method to reopen a closed topic in a forum supergroup chat. The bot must
      # be an administrator in the chat for this to work and must have the
      # can_manage_topics administrator rights, unless it is the
      # creator of the topic.
      # Returns True on success.
      def reopen_forum_topic(
        chat,
        message_thread_id
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "reopenForumTopic", {
          chat_id:           chat_id,
          message_thread_id: message_thread_id,
        })
      end

      # Use this method to delete a forum topic along with all its messages in a forum
      # supergroup chat. The bot must be an administrator in the chat for this to
      # work and must have the can_delete_messages administrator rights.
      # Returns True on success.
      def delete_forum_topic(
        chat,
        message_thread_id
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "deleteForumTopic", {
          chat_id:           chat_id,
          message_thread_id: message_thread_id,
        })
      end

      # Use this method to clear the list of pinned messages in a forum topic. The bot
      # must be an administrator in the chat for this to work and must have the
      # can_pin_messages administrator right in the supergroup.
      # Returns True on success.
      def unpin_all_forum_topic_messages(
        chat,
        message_thread_id
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id

        request(Bool, "unpinAllForumTopicMessages", {
          chat_id:           chat_id,
          message_thread_id: message_thread_id,
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
        request(Tourmaline::Model::TFile, "getFile", {
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

        request(Tourmaline::Model::UserProfilePhotos, "getUserProfilePhotos", {
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
      def ban_chat_member(
        chat,
        user,
        until_date = nil,
        revoke_messages = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id
        until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)

        request(Bool, "banChatMember", {
          chat_id:         chat_id,
          user_id:         user_id,
          until_date:      until_date,
          revoke_messages: revoke_messages,
        })
      end

      def kick_chat_member(*args, **kwargs)
        ban_chat_member(*args, **kwargs)
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
        can_manage_video_chats = nil,
        can_restrict_members = nil,
        can_pin_messages = nil,
        can_promote_members = nil,
        can_manage_topics = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "promoteChatMember", {
          chat_id:                chat_id,
          user_id:                user_id,
          is_anonymous:           is_anonymous,
          until_date:             until_date,
          can_manage_chat:        can_manage_chat,
          can_change_info:        can_change_info,
          can_post_messages:      can_post_messages,
          can_edit_messages:      can_edit_messages,
          can_delete_messages:    can_delete_messages,
          can_invite_users:       can_invite_users,
          can_manage_video_chats: can_manage_video_chats,
          can_restrict_members:   can_restrict_members,
          can_pin_messages:       can_pin_messages,
          can_promote_members:    can_promote_members,
          can_manage_topics:      can_manage_topics,
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

      # Use this method to ban a channel chat in a supergroup or a channel. The owner
      # of the chat will not be able to send messages and join live streams on
      # behalf of the chat, unless it is unbanned first. The bot must be an
      # administrator in the supergroup or channel for this to work and
      # must have the appropriate administrator rights.
      # Returns True on success.
      def ban_chat_sender_chat(chat, sender_chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        sender_chat_id = sender_chat.is_a?(Int::Primitive) ? sender_chat : sender_chat.id

        request(Bool, "banChatSenderChat", {
          chat_id:        chat_id,
          sender_chat_id: sender_chat_id,
        })
      end

      # Use this method to unban a previously banned channel chat in a supergroup or channel.
      # The bot must be an administrator for this to work and must have the
      # appropriate administrator rights.
      # Returns True on success.
      def unban_chat_sender_chat(chat, sender_chat)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        sender_chat_id = sender_chat.is_a?(Int::Primitive) ? sender_chat : sender_chat.id

        request(Bool, "unbanChatSenderChat", {
          chat_id:        chat_id,
          sender_chat_id: sender_chat_id,
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

      # Use this method to create an additional invite link for a chat. The bot must be an
      # administrator in the chat for this to work and must have the appropriate
      # administrator rights. The link can be revoked using the method
      # revokeChatInviteLink.
      # Returns the new invite link as ChatInviteLink object.
      def create_chat_invite_link(
        chat,
        name = nil,
        expire_date = nil,
        member_limit = nil,
        creates_join_request = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        expire_date = expire_date.to_unix unless (expire_date.is_a?(Int) || expire_date.nil?)

        request(Tourmaline::Model::ChatInviteLink, "createChatInviteLink", {
          chat_id:              chat_id,
          name:                 name,
          expire_date:          expire_date,
          member_limit:         member_limit,
          creates_join_request: creates_join_request,
        })
      end

      # Use this method to edit a non-primary invite link created by the bot. The
      # bot must be an administrator in the chat for this to work and must
      # have the appropriate administrator rights.
      # Returns the edited invite link as a ChatInviteLink object.
      def edit_chat_invite_link(
        chat,
        invite_link,
        name = nil,
        expire_date = nil,
        member_limit = nil,
        creates_join_request = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        invite_link = invite_link.is_a?(String) ? invite_link : invite_link.invite_link
        expire_date = expire_date.to_unix unless (expire_date.is_a?(Int) || expire_date.nil?)

        request(Tourmaline::Model::ChatInviteLink, "editChatInviteLink", {
          chat_id:              chat_id,
          invite_link:          invite_link,
          name:                 name,
          expire_date:          expire_date,
          member_limit:         member_limit,
          creates_join_request: creates_join_request,
        })
      end

      # Use this method to revoke an invite link created by the bot. If the primary link
      # is revoked, a new link is automatically generated. The bot must be an
      # administrator in the chat for this to work and must have the
      # appropriate administrator rights.
      # Returns the revoked invite link as ChatInviteLink object.
      def revoke_chat_invite_link(chat, invite_link)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        invite_link = invite_link.is_a?(String) ? invite_link : invite_link.invite_link

        request(Tourmaline::Model::ChatInviteLink, "revokeChatInviteLink", {
          chat_id:     chat_id,
          invite_link: invite_link,
        })
      end

      # Use this method to approve a chat join request. The bot must be an administrator
      # in the chat for this to work and must have the can_invite_users
      # administrator right.
      # Returns True on success.
      def approve_chat_join_request(chat, user)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "approveChatJoinRequest", {
          chat_id: chat_id,
          user_id: user_id,
        })
      end

      # Use this method to decline a chat join request. The bot must be an administrator
      # in the chat for this to work and must have the can_invite_users
      # administrator right.
      # Returns True on success.
      def decline_chat_join_request(chat, user)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        user_id = user.is_a?(Int) ? user : user.id

        request(Bool, "declineChatJoinRequest", {
          chat_id: chat_id,
          user_id: user_id,
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
        message_thread_id = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        duration = nil,
        preformer = nil,
        title = nil,
        parse_mode = Tourmaline::Client.default_parse_mode,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendAudio", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          audio:                       audio,
          caption:                     caption,
          caption_entities:            caption_entities,
          duration:                    duration,
          preformer:                   preformer,
          title:                       title,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      def send_animation(
        chat,
        animation,
        message_thread_id = nil,
        duration = nil,
        width = nil,
        height = nil,
        thumb = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = Tourmaline::Client.default_parse_mode,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendAnimation", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          animation:                   animation,
          duration:                    duration,
          width:                       width,
          height:                      height,
          thumb:                       thumb,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        last_name = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendContact", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          phone_number:                phone_number,
          first_name:                  first_name,
          last_name:                   last_name,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendDice", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          emoji:                {{ val[1] }},
          disable_notification: disable_notification,
          protect_content: protect_content,
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
        message_thread_id = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = Tourmaline::Client.default_parse_mode,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        document = check_open_local_file(document)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendDocument", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          document:                    document,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        horizontal_accuracy = nil,
        live_period = nil,
        proximity_alert_radius = nil,
        heading = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendLocation", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          latitude:                    latitude,
          longitude:                   longitude,
          horizontal_accuracy:         horizontal_accuracy,
          live_period:                 live_period,
          heading:                     heading,
          proximity_alert_radius:      proximity_alert_radius,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        parse_mode = Tourmaline::Client.default_parse_mode,
        entities = [] of MessageEntity,
        link_preview = false,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendMessage", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          text:                        text,
          parse_mode:                  parse_mode,
          entities:                    entities,
          disable_web_page_preview:    !link_preview,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
          reply_to_message_id:         reply_to_message_id,
          allow_sending_without_reply: allow_sending_without_reply,
          reply_markup:                reply_markup ? reply_markup.to_json : nil,
        })
      end

      def copy_message(
        chat,
        from_chat,
        message,
        message_thread_id = nil,
        caption = nil,
        parse_mode = Tourmaline::Client.default_parse_mode,
        caption_entities = [] of MessageEntity,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        from_chat_id = from_chat.is_a?(Int::Primitive | String) ? from_chat : from_chat.id
        message_id = message.is_a?(Int::Primitive) ? message : message.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request("copyMessage", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          from_chat_id:                from_chat_id,
          message_id:                  message_id,
          caption:                     caption,
          parse_mode:                  parse_mode,
          caption_entities:            caption_entities,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        caption = nil,
        parse_mode = Tourmaline::Client.default_parse_mode,
        caption_entities = [] of MessageEntity,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        photo = check_open_local_file(photo)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int) || reply_to_message.nil? ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendPhoto", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          photo:                       photo,
          caption:                     caption,
          parse_mode:                  parse_mode,
          caption_entities:            caption_entities,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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

        request(Tourmaline::Model::Message, "editMessageMedia", {
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
        media : Array(Tourmaline::Model::InputMediaPhoto | Tourmaline::Model::InputMediaVideo | Tourmaline::Model::InputMediaAudio | Tourmaline::Model::InputMediaDocument),
        message_thread_id = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Array(Tourmaline::Model::Message), "sendMediaGroup", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          media:                       media,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        foursquare_id = nil,
        foursquare_type = nil,
        google_place_id = nil,
        google_place_type = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendVenue", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          latitude:                    latitude,
          longitude:                   longitude,
          title:                       title,
          address:                     address,
          foursquare_id:               foursquare_id,
          foursquare_type:             foursquare_type,
          google_place_id:             google_place_id,
          google_place_type:           google_place_type,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        duration = nil,
        width = nil,
        height = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = Tourmaline::Client.default_parse_mode,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        video = check_open_local_file(video)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendVideo", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          video:                       video,
          duration:                    duration,
          width:                       width,
          height:                      height,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        duration = nil,
        width = nil,
        height = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        parse_mode = Tourmaline::Client.default_parse_mode,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        video_note = check_open_local_file(video_note)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id
        parse_mode = parse_mode && !parse_mode.is_a?(ParseMode) ? ParseMode.parse(parse_mode.to_s) : parse_mode

        request(Tourmaline::Model::Message, "sendVideoNote", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          video_note:                  video_note,
          duration:                    duration,
          width:                       width,
          height:                      height,
          caption:                     caption,
          caption_entities:            caption_entities,
          parse_mode:                  parse_mode,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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
        message_thread_id = nil,
        caption = nil,
        caption_entities = [] of MessageEntity,
        duration = nil,
        preformer = nil,
        title = nil,
        disable_notification = false,
        protect_content = false,
        reply_to_message = nil,
        allow_sending_without_reply = false,
        reply_markup = nil
      )
        voice = check_open_local_file(voice)
        chat_id = chat.is_a?(Int::Primitive | String) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int::Primitive | Nil) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendVoice", {
          chat_id:                     chat_id,
          message_thread_id:           message_thread_id,
          voice:                       voice,
          caption:                     caption,
          caption_entities:            caption_entities,
          duration:                    duration,
          disable_notification:        disable_notification,
          protect_content:             protect_content,
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

        request(Bool | Tourmaline::Model::Message, "editMessageLiveLocation", {
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

        request(Bool | Tourmaline::Model::Message, "stopMessageLiveLocation", {
          chat_id:           chat_id,
          message_id:        message_id,
          inline_message_id: inline_message_id,
          reply_markup:      reply_markup ? reply_markup.to_json : nil,
        })
      end

      # Use this method to change the list of the bot's commands.
      # Returns `true` on success.
      def set_my_commands(
        commands : Array(Tourmaline::Model::BotCommand | NamedTuple(command: String, description: String)),
        scope : BotCommandScope? = nil,
        language_code : String? = nil
      )
        # commands = commands.map(&.to_h.transform_keys(&.to_s))

        request(Bool, "setMyCommands", {
          commands:      commands,
          scope:         scope,
          language_code: language_code,
        })
      end

      # Use this method to get the current list of the bot's commands. Requires no parameters.
      # Returns Array of BotCommand on success.
      def get_my_commands(scope : BotCommandScope? = nil, language_code : String? = nil)
        request(Array(Tourmaline::Model::BotCommand), "getMyCommands", {
          scope:         scope,
          language_code: language_code,
        })
      end

      # Use this method to delete the list of the bot's commands for the given scope and user language.
      # After deletion, higher level commands will be shown to affected users.
      # Returns True on success.
      def delete_my_commands(scope : BotCommandScope? = nil, language_code : String? = nil)
        request(Bool, "deleteMyCommands", {
          scope:         scope,
          language_code: language_code,
        })
      end

      # Use this method to change the default administrator rights requested by the bot when it's added
      # as an administrator to groups or channels. These rights will be suggested to users, but
      # they are are free to modify the list before adding the bot.
      # Returns True on success.
      def set_my_default_adminstrator_rights(rights : ChatAdministratorRights, for_channels : Bool = false)
        request(Bool, "setMyDefaultAdminstratorRights", {
          rights:       rights,
          for_channels: for_channels,
        })
      end

      # Use this method to get the current default administrator rights of the bot.
      # Returns ChatAdministratorRights on success.
      def get_my_default_adminstrator_rights(for_channels : Bool = false)
        request(Tourmaline::Model::ChatAdministratorRights, "getMyDefaultAdminstratorRights", {
          for_channels: for_channels,
        })
      end

      # Use this method to set the result of an interaction with a Web App and send a corresponding
      # message on behalf of the user to the chat from which the query originated.
      # On success, a SentWebAppMessage object is returned.
      def answer_web_app_query(query_id : String, result : InlineQueryResult)
        request(Tourmaline::Model::SentWebAppMessage, "answerWebAppQuery", {
          web_app_query_id: query_id,
          result:           result,
        })
      end

      ########################################################################
      ########################################################################
      ###
      # ##  ██████╗  ██████╗ ██╗     ██╗     ██╗███╗   ██╗ ██████╗
      # ##  ██╔══██╗██╔═══██╗██║     ██║     ██║████╗  ██║██╔════╝
      # ##  ██████╔╝██║   ██║██║     ██║     ██║██╔██╗ ██║██║  ███╗
      # ##  ██╔═══╝ ██║   ██║██║     ██║     ██║██║╚██╗██║██║   ██║
      # ##  ██║     ╚██████╔╝███████╗███████╗██║██║ ╚████║╚██████╔╝
      # ##  ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝
      ###
      ########################################################################
      ########################################################################

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
            sleep(0.5)
          rescue ex : Exceptions::PoolRetryAttemptsExceeded
            raise ex
          rescue ex : Exceptions::RetryAfter
            Log.info { "Flood control exceeded while polling. Retrying in #{ex.seconds} seconds." }
            sleep(ex.seconds)
          rescue ex
            Log.error(exception: ex) { "Error during polling" }
          end
        end
      end

      ########################################################################
      ########################################################################
      ###
      # ## ██╗    ██╗███████╗██████╗ ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗
      # ## ██║    ██║██╔════╝██╔══██╗██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝
      # ## ██║ █╗ ██║█████╗  ██████╔╝███████║██║   ██║██║   ██║█████╔╝ ███████╗
      # ## ██║███╗██║██╔══╝  ██╔══██╗██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║
      # ## ╚███╔███╔╝███████╗██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║
      # ##  ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝
      ###
      ########################################################################
      ########################################################################

      # Start an HTTP server at the specified `host` and `port` that listens for
      # updates using Telegram's webhooks. This is the reccommended way to handle
      # bots in production.
      #
      # Note: Don't forget to call `set_webhook` first! This method does not do it for you.
      def serve(host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false, &block : HTTP::Server::Context ->)
        unless no_middleware_check
          if @middlewares.empty?
            self.use(EventMiddleware.new)
          end
        end

        @webhook_server = server = HTTP::Server.new do |context|
          Fiber.current.telegram_bot_server_http_context = context
          begin
            block.call(context)
          rescue ex
            Log.error(exception: ex) { "Server error" }
          ensure
            Fiber.current.telegram_bot_server_http_context = nil
          end
        end

        if ssl_certificate_path && ssl_key_path
          fl_use_ssl = true
          ssl = OpenSSL::SSL::Context::Server.new
          ssl.certificate_chain = ssl_certificate_path.not_nil!
          ssl.private_key = ssl_key_path.not_nil!
          server.bind_tls(host: host, port: port, context: ssl)
        else
          server.bind_tcp(host: host, port: port)
        end

        Log.info { "Listening for requests at #{host}:#{port}" }
        server.listen
      end

      # :ditto:
      def serve(path = "/", host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false)
        serve(host, port, ssl_certificate_path, ssl_key_path, no_middleware_check) do |context|
          next unless context.request.method == "POST"
          next unless context.request.path == path
          if body = context.request.body
            update = Update.from_json(body)
            handle_update(update)
          end
        end
      end

      # Stops the webhook HTTP server
      def stop_serving
        @webhook_server.try &.close
      end

      # Use this method to specify a url and receive incoming updates via an outgoing webhook.
      # Whenever there is an update for the bot, we will send an HTTPS POST request to the
      # specified url, containing a JSON-serialized `Update`. In case of an unsuccessful
      # request, we will give up after a reasonable amount of attempts.
      # Returns `true` on success.
      #
      # If you'd like to make sure that the Webhook request comes from Telegram, we recommend
      # using a secret path in the URL, e.g. `https://www.example.com/<token>`. Since nobody
      # else knows your bot‘s token, you can be pretty sure it’s us.
      def set_webhook(
        url,
        ip_address = nil,
        certificate = nil,
        max_connections = nil,
        allowed_updates = nil,
        drop_pending_updates = false,
        secret_token = nil
      )
        params = {
          url:                  url,
          ip_address:           ip_address,
          max_connections:      max_connections,
          allowed_updates:      allowed_updates,
          certificate:          certificate,
          drop_pending_updates: drop_pending_updates,
          secret_token:         secret_token,
        }
        Log.info { "Setting webhook to '#{url}'#{" with certificate" if certificate}" }
        request(Bool, "setWebhook", params)
      end

      # Use this to unset the webhook and stop receiving updates to your bot.
      def unset_webhook
        request(Bool, "setWebhook", {url: ""})
      end

      # Use this method to get current webhook status. Requires no parameters.
      # On success, returns a `WebhookInfo` object. If the bot is using
      # `#getUpdates`, will return an object with the
      # url field empty.
      def get_webhook_info
        request(Tourmaline::Model::WebhookInfo, "getWebhookInfo")
      end

      # Use this method to remove webhook integration if you decide to switch
      # back to getUpdates.
      def delete_webhook(drop_pending_updates = false)
        request(Bool, "deleteWebhook", {
          drop_pending_updates: drop_pending_updates,
        })
      end

      # Stops the bot from polling.
      def stop_polling
        Log.info { "Stopping polling" }
        @polling = false
      end

      ########################################################################
      ########################################################################
      ###
      # ## ██████╗  █████╗ ███╗   ███╗███████╗███████╗
      # ## ██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔════╝
      # ## ██║  ███╗███████║██╔████╔██║█████╗  ███████╗
      # ## ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ╚════██║
      # ## ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗███████║
      # ##  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝
      ###
      ########################################################################
      ########################################################################

      # Use this method to send a game.
      # On success, the sent `Message` is returned.
      def send_game(
        chat_id,
        game_short_name,
        message_thread_id = nil,
        disable_notification = nil,
        reply_to_message_id = nil,
        reply_markup = nil
      )
        request(Tourmaline::Model::Message, "sendGame", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          game_short_name:      game_short_name,
          disable_notification: disable_notification,
          reply_to_message_id:  reply_to_message_id,
          reply_markup:         reply_markup,
        })
      end

      # Use this method to set the score of the specified user in a game. On success,
      # if the message was sent by the bot, returns the edited Message, otherwise
      # returns `true`.
      #
      # Raises an error, if the new score is not greater than the user's current
      # score in the chat and force is `false` (default).
      def set_game_score(
        user_id,
        score,
        force = false,
        disable_edit_message = nil,
        chat_id = nil,
        message_id = nil,
        inline_message_id = nil
      )
        request(Bool | Tourmaline::Model::Message, "setGameScore", {
          user_id:              user_id,
          score:                score,
          force:                force,
          disable_edit_message: disable_edit_message,
          chat_id:              chat_id,
          message_id:           message_id,
          inline_message_id:    inline_message_id,
        })
      end

      # Use this method to get data for high score tables. Will return the score of the
      # specified user and several of his neighbors in a game.
      # On success, returns an `Array` of `GameHighScore` objects.
      #
      # > This method will currently return scores for the target user, plus two of his
      # > closest neighbors on each side. Will also return the top three users if the
      # > user and his neighbors are not among them. Please note that this behavior
      # > is subject to change.
      def get_game_high_scores(
        user_id,
        chat_id = nil,
        message_id = nil,
        inline_message_id = nil
      )
        request(Array(Tourmaline::Model::GameHighScore), "getGameHighScores", {
          user_id:           user_id,
          chat_id:           chat_id,
          message_id:        message_id,
          inline_message_id: inline_message_id,
        })
      end

      ########################################################################
      ########################################################################
      ###
      # ## ██████╗  █████╗ ███████╗███████╗██████╗  ██████╗ ██████╗ ████████╗
      # ## ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝
      # ## ██████╔╝███████║███████╗███████╗██████╔╝██║   ██║██████╔╝   ██║
      # ## ██╔═══╝ ██╔══██║╚════██║╚════██║██╔═══╝ ██║   ██║██╔══██╗   ██║
      # ## ██║     ██║  ██║███████║███████║██║     ╚██████╔╝██║  ██║   ██║
      # ## ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝
      ###
      ########################################################################
      ########################################################################

      # Informs a user that some of the Telegram Passport elements they provided contains errors.
      # The user will not be able to re-submit their Passport to you until the errors are fixed
      # (the contents of the field for which you returned the error must change).
      #
      # Returns True on success.
      #
      # Use this if the data submitted by the user doesn't satisfy the standards your service requires
      # for any reason. For example, if a birthday date seems invalid, a submitted document is blurry,
      # a scan shows evidence of tampering, etc. Supply some details in the error message to make
      # sure the user knows how to correct the issues.
      def set_passport_data_errors(
        user_id : Int32,
        errors : Array(Tourmaline::Model::PassportElementError)
      )
        request(Bool, "sendSticker", {
          user_id: user_id,
          errors:  errors,
        })
      end

      ########################################################################
      ########################################################################
      ###
      # ## ██████╗  █████╗ ██╗   ██╗███╗   ███╗███████╗███╗   ██╗████████╗███████╗
      # ## ██╔══██╗██╔══██╗╚██╗ ██╔╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
      # ## ██████╔╝███████║ ╚████╔╝ ██╔████╔██║█████╗  ██╔██╗ ██║   ██║   ███████╗
      # ## ██╔═══╝ ██╔══██║  ╚██╔╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   ╚════██║
      # ## ██║     ██║  ██║   ██║   ██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   ███████║
      # ## ╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
      ###
      ########################################################################
      ########################################################################

      # Use this method to send invoices.
      # On success, the sent `Message` is returned.
      def send_invoice(
        chat,
        title,
        description,
        payload,
        provider_token,
        currency,
        prices,
        message_thread_id = nil,
        max_tip_amount = nil,
        suggested_tip_amounts = nil,
        start_parameter = nil,
        provider_data = nil,
        photo_url = nil,
        photo_size = nil,
        photo_width = nil,
        photo_height = nil,
        need_name = nil,
        need_phone_number = nil,
        need_email = nil,
        need_shipping_address = nil,
        send_phone_number_to_provider = nil,
        send_email_to_provider = nil,
        is_flexible = nil,
        disable_notification = nil,
        reply_to_message = nil,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int) ? chat : chat.id
        reply_to_message_id = reply_to_message.is_a?(Int) ? reply_to_message : reply_to_message.message_id

        request(Tourmaline::Model::Message, "sendInvoice", {
          chat_id:                       chat_id,
          message_thread_id:             message_thread_id,
          title:                         title,
          description:                   description,
          payload:                       payload,
          provider_token:                provider_token,
          currency:                      currency,
          prices:                        prices.to_json,
          max_tip_amount:                max_tip_amount,
          suggested_tip_amounts:         suggested_tip_amounts,
          start_parameter:               start_parameter,
          provider_data:                 provider_data,
          photo_url:                     photo_url,
          photo_size:                    photo_size,
          photo_width:                   photo_width,
          photo_height:                  photo_height,
          need_name:                     need_name,
          need_phone_number:             need_phone_number,
          need_email:                    need_email,
          need_shipping_address:         need_shipping_address,
          send_phone_number_to_provider: send_phone_number_to_provider,
          send_email_to_provider:        send_email_to_provider,
          is_flexible:                   is_flexible,
          disable_notification:          disable_notification,
          reply_to_message_id:           reply_to_message_id,
          reply_markup:                  reply_markup,
        })
      end

      # Use this method to create a link for an invoice.
      # Returns the created invoice link as String on success.
      def create_invoice_link(
        title,
        description,
        payload,
        provider_token,
        currency,
        prices,
        max_tip_amount = nil,
        suggested_tip_amounts = nil,
        provider_data = nil,
        photo_url = nil,
        photo_size = nil,
        photo_width = nil,
        photo_height = nil,
        need_name = nil,
        need_phone_number = nil,
        need_email = nil,
        need_shipping_address = nil,
        send_phone_number_to_provider = nil,
        send_email_to_provider = nil,
        is_flexible = nil
      )
        request(String, "createInvoiceLink", {
          title:                         title,
          description:                   description,
          payload:                       payload,
          provider_token:                provider_token,
          currency:                      currency,
          prices:                        prices.to_json,
          max_tip_amount:                max_tip_amount,
          suggested_tip_amounts:         suggested_tip_amounts,
          provider_data:                 provider_data,
          photo_url:                     photo_url,
          photo_size:                    photo_size,
          photo_width:                   photo_width,
          photo_height:                  photo_height,
          need_name:                     need_name,
          need_phone_number:             need_phone_number,
          need_email:                    need_email,
          need_shipping_address:         need_shipping_address,
          send_phone_number_to_provider: send_phone_number_to_provider,
          send_email_to_provider:        send_email_to_provider,
          is_flexible:                   is_flexible,
        })
      end

      # If you sent an invoice requesting a shipping address and the parameter is_flexible
      # was specified, the Client API will send a `Update` with a shipping_query field to
      # the bot. Use this method to reply to shipping queries.
      # On success, `true` is returned.
      def answer_shipping_query(
        shipping_query_id,
        ok,
        shipping_options = nil,
        error_message = nil
      )
        request(Tourmaline::Model::Message, "answerShippingQuery", {
          shipping_query_id: shipping_query_id,
          ok:                ok,
          shipping_options:  shipping_options,
          error_message:     error_message,
        })
      end

      # Once the user has confirmed their payment and shipping details, the Client API sends
      # the final confirmation in the form of a `Update` with the field pre_checkout_query.
      # Use this method to respond to such pre-checkout queries.
      # On success, `true` is returned.
      #
      # > Note: The Client API must receive an answer within 10 seconds after the
      # > pre-checkout query was sent.
      def answer_pre_checkout_query(
        pre_checkout_query_id,
        ok,
        error_message = nil
      )
        request(Bool, "answerPreCheckoutQuery", {
          pre_checkout_query_id: pre_checkout_query_id,
          ok:                    ok,
          error_message:         error_message,
        })
      end

      # Convenience method to create and `Array` of `LabledPrice` from an `Array`
      # of `NamedTuple(label: String, amount: Int32)`.
      # TODO: Replace with a builder of some kind
      def labeled_prices(lp : Array(NamedTuple(label: String, amount: Int32)))
        lp.reduce([] of Tourmaline::LabeledPrice) { |acc, i|
          acc << Tourmaline::LabeledPrice.new(label: i[:label], amount: i[:amount])
        }
      end

      # Convenience method to create an `Array` of `ShippingOption` from a
      # `NamedTuple(id: String, title: String, prices: Array(LabeledPrice))`.
      # TODO: Replace with a builder of some kind
      def shipping_options(options : Array(NamedTuple(id: String, title: String, prices: Array(Tourmaline::Model::LabeledPrice))))
        lp.reduce([] of Tourmaline::ShippingOption) { |acc, i|
          acc << Tourmaline::ShippingOption.new(id: i[:id], title: i[:title], prices: i[:prices])
        }
      end

      ########################################################################
      ########################################################################
      ###
      # ## ██████╗  ██████╗ ██╗     ██╗     ███████╗
      # ## ██╔══██╗██╔═══██╗██║     ██║     ██╔════╝
      # ## ██████╔╝██║   ██║██║     ██║     ███████╗
      # ## ██╔═══╝ ██║   ██║██║     ██║     ╚════██║
      # ## ██║     ╚██████╔╝███████╗███████╗███████║
      # ## ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝
      ###
      ########################################################################
      ########################################################################

      # Use this method to send a native poll.
      # On success, the sent Message is returned.
      def send_poll(
        chat,
        question : String,
        options : Array(String), # 2-10 strings, up to 100 chars each
        anonymous : Bool = true,
        type : Poll::Type = Poll::Type::Regular,
        allows_multiple_answers : Bool = false,
        correct_option_id : Int32? = nil, # required for quiz mode
        close_date : Time? = nil,
        open_period : Int32? = nil,
        closed : Bool = false,
        disable_notification : Bool = false,
        reply_to_message = nil,
        reply_markup = nil
      )
        if options.size < 2 || options.size > 10
          raise "Incorrect option count. Expected 2-10, given #{options.size}."
        end

        if options.any? { |o| o.size < 1 || o.size > 300 }
          raise "Incorrect option size. Poll options must be between 1 and 300 characters."
        end

        if type == Poll::Type::Quiz && !correct_option_id
          raise "Quiz poll type requires a correct_option_id be set."
        end

        chat_id = chat.is_a?(Int) ? chat : chat.id
        if reply_to_message
          reply_to_message = reply_to_message.is_a?(Int) ? reply_to_message : reply_to_message.message_id
        end

        request(Tourmaline::Model::Message, "sendPoll", {
          chat_id:                 chat_id,
          question:                question,
          options:                 options,
          anonymous:               anonymous,
          type:                    type.to_s,
          allows_multiple_answers: allows_multiple_answers,
          correct_option_id:       correct_option_id,
          close_date:              close_date.try &.to_unix,
          is_closed:               closed,
          disable_notification:    disable_notification,
          reply_to_message_id:     reply_to_message,
          reply_markup:            reply_markup,
        })
      end

      # Use this method to stop a poll which was sent by the bot.
      # On success, the stopped `Poll` with the final results is returned.
      def stop_poll(
        chat,
        message,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int) ? chat : chat.id
        message_id = message.is_a?(Int) ? message : message.message_id

        request(Tourmaline::Model::Poll, "stopPoll", {
          chat_id:      chat_id,
          message_id:   message_id,
          reply_markup: reply_markup,
        })
      end

      ########################################################################
      ########################################################################
      ###
      # ## ███████╗████████╗██╗ ██████╗██╗  ██╗███████╗██████╗ ███████╗
      # ## ██╔════╝╚══██╔══╝██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗██╔════╝
      # ## ███████╗   ██║   ██║██║     █████╔╝ █████╗  ██████╔╝███████╗
      # ## ╚════██║   ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗╚════██║
      # ## ███████║   ██║   ██║╚██████╗██║  ██╗███████╗██║  ██║███████║
      # ## ╚══════╝   ╚═╝   ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
      ###
      ########################################################################
      ########################################################################

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

        request(Tourmaline::Model::Message, "sendSticker", {
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
        request(Tourmaline::Model::Message, "getStickerSet", {
          name: name,
        })
      end

      # Use this method to get information about custom emoji stickers by their identifiers.
      # Returns an Array of Sticker objects.
      def get_custom_emoji_stickers(custom_emoji_ids : Array(String))
        request(Array(Tourmaline::Model::Sticker), "getCustomEmojiStickers", {
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
        request(Tourmaline::Model::TFile, "uploadStickerFile", {
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
