require "logger"
require "halite"

require "./models"
require "./fiber"
require "./middleware"
require "./handlers/*"

module Tourmaline::Bot

  # Parse mode for messages.
  enum ParseMode
    Normal
    Markdown
    HTML
  end

  # Chat actions are what appear at the top of the screen
  # when users are typing, sending files, etc. You can
  # mimic these actions by using the
  # `Client#send_chat_action` method.
  enum ChatAction
    Typing
    UploadPhoto
    RecordVideo
    UploadVideo
    RecordAudio
    UploadAudio
    UploadDocument
    Findlocation
    RecordVideoNote
    UploadVideoNote

    def to_s
      super.to_s.underscore
    end
  end


  enum UpdateAction
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

    def to_s
      super.to_s.underscore
    end
  end

  # Client is synonymous with Bot. You can create a bot by
  # creating an instance of the `Tourmaline::Client`
  # class and setting the correct `api_key`. For
  # information on all the available methods,
  # see below.
  #
  # ### Examples:
  #
  # Echo bot:
  # ```
  # require "tourmaline/bot"
  #
  # bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])
  #
  # bot.command("echo") do |message, params|
  #   text = params.join(" ")
  #   bot.send_message(message.chat.id, text)
  #   bot.delete_message(message.chat.id, message.message_id)
  # end
  #
  # bot.poll
  # ```
  #
  # Inline query bot:
  # ```
  # require "tourmaline/bot"
  #
  # bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])
  #
  # bot.on(:inline_query) do |update|
  #   query = update.inline_query.not_nil!
  #   results = [] of Tourmaline::Bot::Model::InlineQueryResult
  #
  #   results << Tourmaline::Bot::Model::InlineQueryResultArticle.new(
  #     id: "query",
  #     title: "Inline title",
  #     input_message_content: Tourmaline::Bot::Model::InputTextMessageContent.new("Click!"),
  #     description: "Your query: #{query.query}",
  #   )
  #
  #   results << Tourmaline::Bot::Model::InlineQueryResultPhoto.new(
  #     id: "photo",
  #     caption: "Telegram logo",
  #     photo_url: "https://telegram.org/img/t_logo.png",
  #     thumb_url: "https://telegram.org/img/t_logo.png"
  #   )
  #
  #   results << Tourmaline::Bot::Model::InlineQueryResultGif.new(
  #     id: "gif",
  #     gif_url: "https://telegram.org/img/tl_card_wecandoit.gif",
  #     thumb_url: "https://telegram.org/img/tl_card_wecandoit.gif"
  #   )
  #
  #   bot.answer_inline_query(query.id, results)
  # end
  #
  # bot.poll
  # ```
  #
  # Kitty bot (using custom keyboard):
  # ```
  # require "tourmaline/bot"
  #
  # bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])
  #
  # reply_markup = Tourmaline::Bot::Model::ReplyKeyboardMarkup.new([
  #   ["/kitty"], ["/kittygif"],
  # ])
  #
  # bot.command(["start", "help"]) do |message|
  #   bot.send_message(
  #     message.chat.id,
  #     "😺 Use commands: /kitty, /kittygif and /about",
  #     reply_markup: reply_markup)
  # end
  #
  # bot.command("about") do |message|
  #   text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
  #   bot.send_message(message.chat.id, text)
  # end
  #
  # bot.command(["kitty", "kittygif"]) do |message|
  #   # The time hack is to get around Telegrsm's image cache
  #   api = "https://thecatapi.com/api/images/get?time=%{time}&format=src&type=" % {time: Time.now}
  #   cmd = message.text.not_nil!.split(" ")[0]
  #
  #   if cmd == "/kitty"
  #     bot.send_chat_action(message.chat.id, :upload_photo)
  #     bot.send_photo(message.chat.id, api + "jpg")
  #   else
  #     bot.send_chat_action(message.chat.id, :upload_document)
  #     bot.send_document(message.chat.id, api + "gif")
  #   end
  # end
  #
  # bot.poll
  # ```
  #
  # Webhook bot (using [ngrok.cr](https://github.com/watzon/ngrok.cr)):
  # ```
  # require "ngrok"
  # require "tourmaline/bot"
  #
  # Ngrok.start({addr: "127.0.0.1:3400"}) do |ngrok|
  #   bot = Tourmaline::Bot::Client.new(ENV["API_KEY"])
  #
  #   bot.command("echo") do |message, params|
  #     text = params.join(" ")
  #     bot.send_message(message.chat.id, text)
  #     bot.delete_message(message.chat.id, message.message_id)
  #   end
  #
  #   bot.set_webhook(ngrok.ngrok_url_https)
  #   bot.serve("127.0.0.1", 3400)
  # end
  # ```
  class Client
    include CommandHandler
    include EventHandler

    API_URL = "https://api.telegram.org/"

    @logger : Logger?

    @endpoint_url : String

    @bot_info : Model::User

    @bot_name : String

    @polling : Bool = false

    @next_offset : Int64 = 0.to_i64

    getter :bot_info, :bot_name, :polling

    # Create a new instance of `Tourmaline::Bot::Client`. It is
    # highly recommended to set `@api_key` at an environment
    # variable. `@logger` can be any logger that extends
    # Crystal's built in Logger.
    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil
    )
      @endpoint_url = ::File.join(API_URL, "bot" + @api_key)
      @bot_info = get_me
      @bot_name = @bot_info.username.not_nil!

      load_default_middleware
    end

    # Convenience method to check if this bot is an admin in
    # the current chat. See `Client#get_chat_administrators`
    # for more info.
    def is_admin?(chat_id)
      admins = get_chat_administrators(chat_id)
      admins.any? { |a| a.user.id = @bot_info.id }
    end

    # A simple method for testing your bot's auth token. Requires
    # no parameters. Returns basic information about the bot
    # in form of a `Model::User` object.
    def get_me
      response = request("getMe")
      Model::User.from_json(response)
    end

    # Use this method to receive incoming updates using long polling
    # ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)).
    # An `Array` of `Model::Update` objects is returned.
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

      updates = Array(Model::Update).from_json(response)

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

    # Use this method to delete a `Model::Message`, including service messages,
    # with the following limitations:
    # - A message can only be deleted if it was sent less than 48 hours ago.
    # - Bots can delete outgoing messages in private chats, groups, and supergroups.
    # - Bots can delete incoming messages in private chats.
    # - Bots granted can_post_messages permissions can delete outgoing messages in channels.
    # - If the bot is an administrator of a group, it can delete any message there.
    # - If the bot has `can_delete_messages` permission in a supergroup or a
    #   channel, it can delete any message there.
    # Returns `true` on success.
    def delete_message(chat_id, message_id)
      response = request("deleteMessage", {
        chat_id:    chat_id,
        message_id: message_id,
      })

      response == "true"
    end

    # Use this method to edit captions of messages. On success,
    # if edited message is sent by the bot, the edited
    # `Model::Message` is returned, otherwise `true`
    # is returned.
    def edit_message_caption(
      chat_id,
      caption,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("editMesasageCaption", {
        chat_id:           chat_id,
        caption:           caption,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      response.is_a?(String) ? response == "true" : Model::Message.from_json(response)
    end

    # Use this method to edit only the reply markup of messages.
    # On success, if edited message is sent by the bot, the
    # edited `Message` is returned, otherwise `true` is
    # returned.
    def edit_message_reply_markup(
      chat_id,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("editMesasageReplyMarkup", {
        chat_id:           chat_id,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      response.is_a?(String) ? response == "true" : Model::Message.from_json(response)
    end

    # Use this method to edit text and game messages. On success, if
    # edited message is sent by the bot, the edited `Message`
    # is returned, otherwise `true` is returned.
    def edit_message_text(
      chat_id,
      text,
      message_id = nil,
      inline_message_id = nil,
      parse_mode = ParseMode::Normal,
      disable_link_preview = false,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("editMessageText", {
        chat_id:                  chat_id,
        message_id:               message_id,
        inline_message_id:        inline_message_id,
        text:                     text,
        parse_mode:               parse_mode,
        disable_web_page_preview: disable_link_preview,
        disable_notification:     disable_notification,
        reply_to_message_id:      reply_to_message_id,
        reply_markup:             reply_markup ? reply_markup.to_json : nil,
      })

      Message.from_json(response)
    end

    # Use this method to forward messages of any kind. On success,
    # the sent `Message` is returned.
    def forward_message(
      chat_id,
      from_chat_id,
      message_id,
      disable_notification = false
    )
      response = request("forwardMessage", {
        chat_id:              chat_id,
        from_chat_id:         from_chat_id,
        message_id:           message_id,
        disable_notification: disable_notification,
      })

      Model::Message.from_json(response)
    end

    # Use this method to get up to date information about the chat
    # (current name of the user for one-on-one conversations,
    # current username of a user, group or channel, etc.).
    # Returns a `Model::Chat` object on success.
    def get_chat(chat_id)
      response = request("getChat", {
        chat_id: chat_id,
      })

      Model::Chat.from_json(response)
    end

    # Use this method to get a list of administrators in a chat. On success,
    # returns an `Array` of `ChatMember` objects that contains information
    # about all chat administrators except other bots. If the chat is a
    # group or a supergroup and no administrators were appointed,
    # only the creator will be returned.
    def get_chat_administrators(chat_id)
      response = request("getChatAdministrators", {
        chat_id: chat_id,
      })

      Array(Model::ChatMember).from_json(response)
    end

    # Use this method to get information about a member of a chat. Returns a
    # `Model::ChatMember` object on success.
    def get_chat_member(chat_id, user_id)
      response = request("getChatMember", {
        chat_id: chat_id,
        user_id: user_id
      })

      Array(Model::ChatMember).from_json(response)
    end

    # Use this method to get the number of members in a chat.
    # Returns `Int32` on success.
    def get_chat_members_count(chat_id)
      response = request("getChatMembersCount", {
        chat_id: chat_id
      })

      response.to_i32
    end

    # Use this method to get basic info about a file and prepare it for downloading.
    # For the moment, bots can download files of up to **20MB** in size. On success,
    # a `Model::File` object is returned. The file can then be downloaded via the
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

      Model::File.from_json(response)
    end

    # Returns a download link for a `File`.
    def get_file_link(file)
      if file.file_path
        return ::File.join(@endpoint_url, file.file_path)
      end

      nil
    end

    # Use this method to get a list of profile pictures for a user.
    # Returns a `Model::UserProfilePhotos` object.
    def get_user_profile_photos(
      user_id,
      offset = nil,
      limit = nil
    )
      response = request("getUserProfilePhotos", {
        user_id: user_id,
        offset:  offset,
        limit:   limit,
      })

      Model::UserProfilePhotos.from_json(response)
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
      chat_id,
      user_id,
      until_date = nil
    )
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
      chat_id,
      user_id
    )
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
      chat_id,
      user_id,
      until_date = nil,
      can_see_messages = nil,
      can_send_media_messages = nil,
      can_send_other_messages = nil,
      can_add_web_page_previews = nil
    )
      response = request("restrictChatMember", {
        chat_id:                   chat_id,
        user_id:                   user_id,
        until_date:                until_date,
        can_see_messages:          can_see_messages,
        can_send_media_messages:   can_send_media_messages,
        can_send_other_messages:   can_send_other_messages,
        can_add_web_page_previews: can_add_web_page_previews,
      })

      response == "true"
    end

    # Use this method to promote or demote a user in a supergroup or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the appropriate admin rights. Pass False for all boolean
    # parameters to demote a user.
    # Returns `true` on success.
    def promote_chat_member(
      chat_id,
      user_id,
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
    def export_chat_invite_link(chat_id)
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
    def set_chat_photo(chat_id, photo)
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
    def delete_chat_photo(chat_id)
      response = request("deleteChatPhoto", {
        chat_id: chat_id,
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
    def set_chat_title(chat_id, title)
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
    def set_chat_description(chat_id, description)
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
    def pin_chat_message(chat_id, message_id, disable_notification = false)
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
    def unpin_chat_message(chat_id)
      response = request("unpinChatMessage", {
        chat_id: chat_id,
      })

      response == "true"
    end

    # Use this method for your bot to leave a group,
    # supergroup, or channel.
    # Returns `true` on success.
    def leave_chat(chat_id)
      response = request("leaveChat", {
        chat_id: chat_id,
      })

      Model::Chat.from_json(response)
    end

    # Use this method to remove webhook integration if you decide to switch
    # back to getUpdates.
    # Returns `true` on success.
    # Requires no parameters.
    def delete_webhook
      response = request("deleteWebhook")
      response == "true"
    end

    # Use this method to send audio files, if you want Telegram clients to display
    # them in the music player. Your audio must be in the `.mp3` format.
    # On success, the sent `Model::Message` is returned. Bots can currently
    # send audio files of up to **50 MB** in size, this limit may be
    # changed in the future.
    #
    # For sending voice messages, use the `#sendVoice` method instead.
    # TODO: Add filesize checking and validation.
    def send_audio(
      chat_id,
      audio,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
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

      Model::Message.from_json(response)
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
      chat_id,
      action : ChatAction
    )
      response = request("sendChatAction", {
        chat_id: chat_id,
        action:  action.to_s,
      })

      response == "true"
    end

    # Use this method to send phone contacts.
    # On success, the sent `Model::Message` is returned.
    def send_contact(
      chat_id,
      phone_number,
      first_name,
      last_name = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendContact", {
        chat_id:              chat_id,
        phone_number:         phone_number,
        first_name:           first_name,
        last_name:            last_name,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to send general files.
    # On success, the sent `Model::Message` is returned. Bots can currently send files
    # of any type of up to **50 MB** in size, this limit
    # may be changed in the future.
    # TODO: Add filesize checking and validation.
    def send_document(
      chat_id,
      document,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendDocument", {
        chat_id:              chat_id,
        document:             document,
        caption:              caption,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to send point on the map.
    # On success, the sent `Model::Message` is returned.
    def send_location(
      chat_id,
      latitude,
      longitude,
      live_period = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendLocation", {
        chat_id:              chat_id,
        latitude:             latitude,
        longitude:            longitude,
        live_period:          live_period,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to send text messages.
    # On success, the sent `Model::Message` is returned.
    def send_message(
      chat_id,
      text,
      parse_mode = ParseMode::Normal,
      disable_link_preview = false,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("sendMessage", {
        chat_id:                  chat_id,
        text:                     text,
        parse_mode:               parse_mode,
        disable_web_page_preview: disable_link_preview,
        disable_notification:     disable_notification,
        reply_to_message_id:      reply_to_message_id,
        reply_markup:             reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to send photos.
    # On success, the sent `Model::Message` is returned.
    def send_photo(
      chat_id,
      photo,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendPhoto", {
        chat_id:              chat_id,
        photo:                photo,
        caption:              caption,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to send a group of photos or videos as an album.
    # On success, an array of the sent `Messages` is returned.
    # TODO: Test this.
    def send_media_group(
      chat_id,
      media,
      disable_notification = false,
      reply_to_message_id = nil
    )
      response = request("sendMediaGroup", {
        chat_id:              chat_id,
        media:                media,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
      })

      Array(Model::Message).from_json(response)
    end

    # Use this method to send information about a venue.
    # On success, the sent `Model::Message` is returned.
    def send_venue(
      chat_id,
      latitude,
      longitude,
      title,
      address,
      foursquare_id = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
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

      Model::Message.from_json(response)
    end

    # Use this method to send video files, Telegram clients support mp4 videos
    # (other formats may be sent as Document).
    # On success, the sent `Model::Message` is returned. Bots can currently send
    # video files of up to **50 MB** in size, this limit may be
    # changed in the future.
    # TODO: Add filesize checking and validation.
    def send_video(
      chat_id,
      video,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
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

      Model::Message.from_json(response)
    end

    # As of [v.4.0](https://telegram.org/blog/video-messages-and-telescope), Telegram
    # clients support rounded square `mp4` videos of up to **1** minute long.
    # Use this method to send video messages.
    # On success, the sent `Model::Message` is returned.
    def send_video_note(
      chat_id,
      video_note,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
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

      Model::Message.from_json(response)
    end

    # Use this method to send audio files, if you want Telegram clients to display the
    # file as a playable voice message. For this to work, your audio must be in
    # an `.ogg` file encoded with OPUS (other formats may be sent as `Audio`
    # or `Document`).
    # On success, the sent `Model::Message` is returned. Bots can currently send voice
    # messages of up to **50 MB** in size, this limit may be changed in the future.
    # TODO: Add filesize checking and validation.
    def send_voice(
      chat_id,
      voice,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendVoice", {
        chat_id:              chat_id,
        voice:                voice,
        caption:              caption,
        duration:             duration,
        disable_notification: disable_notification,
        reply_to_message_id:  reply_to_message_id,
        reply_markup:         reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # Use this method to edit live location messages. A location can be edited until
    # its live_period expires or editing is explicitly disabled by a call to
    # `#stopMessageLiveLocation`.
    # On success, if the edited message wasn't by the bot, the edited `Model::Message` is
    # returned, otherwise `true` is returned.
    def edit_message_live_location(
      chat_id,
      latitude,
      longitude,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

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

      Model::Message.from_json(response)
    end

    # Use this method to stop updating a live location message before
    # live_period expires.
    # On success, if the message was sent by the bot, the sent
    # `Model::Message` is returned, otherwise `true` is returned.
    def stop_message_live_location(
      chat_id,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil
    )
      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("stopMessageLiveLocation", {
        chat_id:           chat_id,
        message_id:        message_id,
        inline_message_id: inline_message_id,
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
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

      logger.info("Polling for updates")
      while @polling
        begin
          updates = get_updates
          updates.each do |u|
            spawn handle_update(u)
          end
        rescue exception
          logger.error(exception)
        end
      end
    end

    # Stops the bot from polling.
    def stop_polling
      @polling = false
    end

    ##########################
    #        WEBHOOK         #
    ##########################

    # Start an HTTP server at the specified `address` and `port` that listens for
    # updates using Telegram's webhooks. This is the reccommended way to handle
    # bots in production.
    def serve(address = "127.0.0.1", port = 8080, ssl_certificate_path = nil, ssl_key_path = nil)
      server = HTTP::Server.new do |context|
        begin
          Fiber.current.telegram_bot_server_http_context = context
          handle_update(Model::Update.from_json(context.request.body.not_nil!))
        rescue exception
          logger.error(exception)
        ensure
          Fiber.current.telegram_bot_server_http_context = nil
        end
      end

      server.bind_tcp address, port
      server.listen
      if ssl_certificate_path && ssl_key_path
        flUseSSL = true
        ssl = OpenSSL::SSL::Context::Server.new
        ssl.certificate_chain = ssl_certificate_path.not_nil!
        ssl.private_key = ssl_key_path.not_nil!
        server.bind_tls address, port, ssl
      else
        server.bind_tcp address, port
      end

      logger.info("Listening for Telegram requests at #{address}:#{port}#{" with tls" if flUseSSL}")
      server.listen
    end

    # Use this method to specify a url and receive incoming updates via an outgoing webhook.
    # Whenever there is an update for the bot, we will send an HTTPS POST request to the
    # specified url, containing a JSON-serialized `Model::Update`. In case of an unsuccessful
    # request, we will give up after a reasonable amount of attempts.
    # Returns `true` on success.
    #
    # If you'd like to make sure that the Webhook request comes from Telegram, we recommend
    # using a secret path in the URL, e.g. `https://www.example.com/<token>`. Since nobody
    # else knows your bot‘s token, you can be pretty sure it’s us.
    def set_webhook(url, certificate = nil, max_connections = nil, allowed_updates = @allowed_updates)
      params = {url: url, max_connections: max_connections, allowed_updates: allowed_updates, certificate: certificate}
      logger.info("Setting webhook to '#{url}'#{" with certificate" if certificate}")
      request("setWebhook", params)
    end

    # Use this to unset the webhook and stop receiving updates to your bot.
    def unset_webhook
      request("setWebhook", {url: ""})
    end

    # Use this method to get current webhook status. Requires no parameters.
    # On success, returns a `WebhookInfo` object. If the bot is using
    # `#getUpdates`, will return an object with the
    # url field empty.
    def get_webhook_info
      response = request("getWebhookInfo")
      Model::WebhookInfo.from_json(response)
    end

    ##########################
    #        STICKERS        #
    ##########################

    # Use this method to send `.webp` stickers.
    # On success, the sent `Model::Message` is returned.
    #
    # See: https://core.telegram.org/bots/api#stickers for more info.
    def send_sticker(
      chat_id : Int32 | String,
      sticker : Model::InputFile | String,
      disable_notification : Bool? = nil,
      reply_to_message_id : Int32? = nil,
      reply_markup = nil
    )
      response = request("sendSticker", {
        chat_id: chat_id,
        sticker: sticker,
        disable_notifications: disable_notifications,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup
      })

      Model::Message.from_json(response)
    end

    # Use this method to get a sticker set.
    # On success, a `StickerSet` object is returned.
    def get_sticker_set(name : String)
      response = request("getStickerSet", {
        name: name
      })

      Model::StickerSet.from_json(response)
    end

    # Use this method to set a new group sticker set for a supergroup. The bot must
    # be an administrator in the chat for this to work and must have the
    # appropriate admin rights. Use the field can_set_sticker_set
    # optionally returned in `#get_chat` requests to check if the
    # bot can use this method.
    # Returns `true` on success.
    def set_chat_sticker_set(chat_id, sticker_set_name)
      response = request("setChatStickerSet", {
        chat_id: chat_id,
        sticker_set_name: sticker_set_name
      })

      response == "true"
    end

    # Use this method to add a new sticker to a set created by the bot.
    # Returns `true` on success.
    def add_sticker_to_set(user_id, name, png_sticker, emojis, mask_position = nil)
      response = request("addStickerToSet", {
        user_id: user_id,
        name: name,
        png_sticker: png_sticker,
        emojis: emojis,
        mask_position: mask_position
      })

      response == "true"
    end

    # Use this method to create new sticker set owned by a user. The bot will be able to
    # edit the created sticker set.
    # Returns `true` on success.
    def create_new_sticker_set(
      user_id,
      name,
      title,
      png_sticker,
      emojis,
      contains_masks = nil,
      mask_position = nil
    )
      response = request("createNewStickerSet", {
        user_id: user_id,
        name: name,
        title: title,
        png_sticker: png_sticker,
        emojis: emojis,
        contains_masks: contains_masks,
        mask_position: mask_position
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
        chat_id: chat_id
      })

      response == "true"
    end

    # Use this method to delete a sticker from a set created by the bot.
    # Returns `true` on success.
    def delete_sticker_from_set(sticker)
      response = request("deleteStickerFromSet", {
        sticker: sticker
      })

      response == "true"
    end

    # Use this method to move a sticker in a set created by the bot to a specific position.
    # Returns `true` on success.
    def set_sticker_position_in_set(sticker, position)
      response = request("setStickerPositionInSet", {
        sticker: sticker,
        position: position
      })

      response == "true"
    end

    # Use this method to upload a .png file with a sticker for later use in
    # `#create_new_sticker_set` and `#add_sticker_to_set` methods (can be
    # used multiple times).
    # Returns the uploaded `Model::File` on success.
    def upload_sticker_file(user_id, png_sticker)
      response = request("uploadStickerFile", {
        user_id: user_id,
        png_sticker: png_sticker
      })

      Model::File.from_json(response)
    end

    ##########################
    #        PAYMENTS        #
    ##########################

    # Use this method to send invoices.
    # On success, the sent `Model::Message` is returned.
    def send_invoice(
      chat_id,
      title,
      description,
      payload,
      provider_token,
      start_parameter,
      currency,
      prices,
      provider_data = nil,
      photo_url = nil,
      photo_size = nil,
      photo_width = nil,
      photo_height = nil,
      need_name = nil,
      need_shipping_address = nil,
      send_phone_number_to_provider = nil,
      send_email_to_provider = nil,
      is_flexible = nil,
      disable_notification = nil,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      response = request("sendInvoice", {
        chat_id:                       chat_id,
        title:                         title,
        description:                   description,
        payload:                       payload,
        provider_token:                provider_token,
        start_parameter:               start_parameter,
        currency:                      currency,
        prices:                        prices,
        provider_data:                 provider_data,
        photo_url:                     photo_url,
        photo_size:                    photo_size,
        photo_width:                   photo_width,
        photo_height:                  photo_height,
        need_name:                     need_name,
        need_shipping_address:         need_shipping_address,
        send_phone_number_to_provider: send_phone_number_to_provider,
        send_email_to_provider:        send_email_to_provider,
        is_flexible:                   is_flexible,
        disable_notification:          disable_notification,
        reply_to_message_id:           reply_to_message_id,
        reply_markup:                  reply_markup ? reply_markup.to_json : nil,
      })

      Model::Message.from_json(response)
    end

    # If you sent an invoice requesting a shipping address and the parameter is_flexible
    # was specified, the Bot API will send a `Model::Update` with a shipping_query field to
    # the bot. Use this method to reply to shipping queries.
    # On success, `true` is returned.
    def answer_shipping_query(
      shipping_query_id,
      ok,
      shipping_options = nil,
      error_message = nil
    )
      response = request("answerShippingQuery", {
        shipping_query_id: shipping_query_id,
        ok:                ok,
        shipping_options:  shipping_options,
        error_message:     error_message,
      })

      Bool.from_json(response)
    end

    # Once the user has confirmed their payment and shipping details, the Bot API sends
    # the final confirmation in the form of a `Model::Update` with the field pre_checkout_query.
    # Use this method to respond to such pre-checkout queries.
    # On success, `true` is returned.
    # Note: The Bot API must receive an answer within 10 seconds after the
    # pre-checkout query was sent.
    def answer_pre_checkout_query(
      pre_checkout_query_id,
      ok,
      error_message
    )
      response = request("answerPreCheckoutQuery", {
        pre_checkout_query_id: pre_checkout_query_id,
        ok:                    ok,
        error_message:         error_message,
      })

      Bool.from_json(response)
    end

    # Convenience method to create and `Array` of `LabledPrice` from an `Array`
    # of `NamedTuple(label: String, amount: Int32)`.
    def labeled_prices(lp : Array(NamedTuple(label: String, amount: Int32)))
      lp.reduce([] of Tourmaline::Bot::Model::LabeledPrice) { |acc, i|
        acc << Tourmaline::Bot::Model::LabeledPrice.new(label: i[:label], amount: i[:amount])
      }
    end

    # Convenience method to create an `Array` of `ShippingOption` from a
    # `NamedTuple(id: String, title: String, prices: Array(LabeledPrice))`.
    def shipping_options(options : Array(NamedTuple(id: String, title: String, prices: Array(LabeledPrice))))
      lp.reduce([] of Tourmaline::Bot::Model::ShippingOption) { |acc, i|
        acc << Tourmaline::Bot::Model::ShippingOption.new(id: i[:id], title: i[:title], prices: i[:prices])
      }
    end

    ##########################
    #         GAMES          #
    ##########################

    # Use this method to send a game.
    # On success, the sent `Model::Message` is returned.
    # TODO: Implement
    def send_game
    end

    # TODO: Implement
    def answer_game_query
    end

    # TODO: Implement
    def set_game_score
    end

    # TODO: Implement
    def get_game_high_scores
    end

    # Sends a json request to the Telegram bot API.
    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)

      response = params.values.any?(&.is_a?(::IO::FileDescriptor)) ?
        Halite.post(method_url, form: params) :
        Halite.post(method_url, params: params)

      result = JSON.parse(response.body)

      if result["result"]?
        return result["result"].to_json
      else
        raise result["description"].to_s
      end
    end

    protected def load_default_middleware
      use CommandMiddleware
    end

    protected def logger : Logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
    end
  end
end
