require "./helpers"
require "./error"
require "./logger"
require "./parse_mode"
require "./chat_action"
require "./update_action"
require "./models/*"
require "./context"
require "./middleware"
require "./event_handler"
require "./dispatcher"
require "./poller"
require "./server"
require "./handlers/*"

require "db/pool"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add event handlers to it.
  class Client
    include Logger

    DEFAULT_API_URL = "https://api.telegram.org/"

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot` to `get_me`.
    getter! bot : User

    getter bot_token : String

    property default_parse_mode : ParseMode

    @dispatcher : Dispatcher?

    private getter pool : DB::Pool(HTTP::Client)

    # Create a new instance of `Tourmaline::Client`.
    #
    # ## Named Arguments
    #
    # `bot_token`
    # :    the bot token you should've received from `@BotFather`
    #
    # `endpoint`
    # :    the API endpoint to use for requests; default is `https://api.telegram.org`, but for
    #      TDLight methods to work you may consider hosting your own instance or using one of
    #      the official ones such as `https://telegram.rest`
    #
    # `default_parse_mode`
    # :    the default parse mode to use for messages; default is `ParseMode::None` (no formatting)
    #
    # `pool_capacity`
    # :    the maximum number of concurrent HTTP connections to use
    #
    # `initial_pool_size`
    # :    the number of HTTP::Client instances to create on init
    #
    # `pool_timeout`
    # :    How long to wait for a new client to be available if the pool is full before throwing a `TimeoutError`
    #
    # `proxy`
    # :    an instance of `HTTP::Proxy::Client` to use; if set, overrides the following `proxy_` args
    #
    # `proxy_uri`
    # :    a URI to use when connecting to the proxy; can be a `URI` instance or a String
    #
    # `proxy_host`
    # :    if no `proxy_uri` is provided, this will be the host for the URI
    #
    # `proxy_port`
    # :    if no `proxy_uri` is provided, this will be the port for the URI
    #
    # `proxy_user`
    # :    a username to use for a proxy that requires authentication
    #
    # `proxy_pass`
    # :    a password to use for a proxy that requires authentication
    def initialize(@bot_token : String,
                   @endpoint = DEFAULT_API_URL,
                   @default_parse_mode : ParseMode = ParseMode::Markdown,
                   pool_capacity = 200,
                   initial_pool_size = 20,
                   pool_timeout = 0.1,
                   proxy = nil,
                   proxy_uri = nil,
                   proxy_host = nil,
                   proxy_port = nil,
                   proxy_user = nil,
                   proxy_pass = nil)
      if !proxy
        if proxy_uri
          proxy_uri = proxy_uri.is_a?(URI) ? proxy_uri : URI.parse(proxy_uri.starts_with?("http") ? proxy_uri : "http://#{proxy_uri}")
          proxy_host = proxy_uri.host
          proxy_port = proxy_uri.port
          proxy_user = proxy_uri.user if proxy_uri.user
          proxy_pass = proxy_uri.password if proxy_uri.password
        end

        if proxy_host && proxy_port
          proxy = HTTP::Proxy::Client.new(proxy_host, proxy_port, username: proxy_user, password: proxy_pass)
        end
      end

      @pool = DB::Pool(HTTP::Client).new(max_pool_size: pool_capacity, initial_pool_size: initial_pool_size, checkout_timeout: pool_timeout) do
        client = HTTP::Client.new(URI.parse(endpoint))
        client.proxy = proxy.dup if proxy
        client
      end

      @bot = self.get_me
    end

    def dispatcher
      @dispatcher ||= Dispatcher.new(self)
    end

    def on(action : UpdateAction, &block : Context ->)
      dispatcher.on(action, &block)
    end

    def on(*actions : Symbol | UpdateAction, &block : Context ->)
      actions.each do |action|
        action = UpdateAction.parse(action.to_s) if action.is_a?(Symbol)
        dispatcher.on(action, &block)
      end
    end

    def use(middleware : Middleware)
      dispatcher.use(middleware)
    end

    def register(*handlers : EventHandler)
      handlers.each do |handler|
        dispatcher.register(handler)
      end
    end

    def poll
      Poller.new(self).start
    end

    def serve(path = "/", host = "127.0.0.1", port = 8081, ssl_certificate_path = nil, ssl_key_path = nil, no_middleware_check = false)
      Server.new(self).serve(path, host, port, ssl_certificate_path, ssl_key_path, no_middleware_check)
    end

    protected def using_connection
      @pool.retry do
        @pool.checkout do |conn|
          yield conn
        end
      end
    end

    # :nodoc:
    MULTIPART_METHODS = %w(sendAudio sendDocument sendPhoto sendVideo sendAnimation sendVoice sendVideoNote sendMediaGroup)

    # Sends a request to the Telegram Client API. Returns the raw response.
    def request_raw(method : String, params = {} of String => String)
      path = File.join("/bot#{bot_token}", method)
      request_internal(path, params, multipart: MULTIPART_METHODS.includes?(method))
    end

    # Sends a request to the Telegram Client API. Returns the response, parsed as a `U`.
    def request(type : U.class, method, params = {} of String => String) forall U
      response = request_raw(method, params)
      type.from_json(response)
    end

    # :nodoc:
    def request_internal(path, params = {} of String => String, multipart = false)
      # Wrap this so pool can attempt a retry
      using_connection do |client|
        Log.debug { "sending ►► #{path.split("/").last}(#{params.to_pretty_json})" }

        begin
          if multipart
            config = build_form_data_config(params)
            response = client.exec(**config.merge({path: path}))
          else
            config = build_json_config(params)
            response = client.exec(**config.merge({path: path}))
          end
        rescue ex : IO::Error | IO::TimeoutError
          Log.error { ex.message }
          Log.trace(exception: ex) { ex.message }

          raise Error::ConnectionLost.new(client)
        end

        result = JSON.parse(response.body)

        Log.debug { "receiving ◄◄ #{result.to_pretty_json}" }

        if result["ok"].as_bool
          result["result"].to_json
        else
          raise Error.from_message(result["description"].as_s)
        end
      end
    end

    protected def extract_id(object)
      return if object.nil?
      if object.responds_to?(:id)
        return object.id
      elsif object.responds_to?(:message_id)
        return object.message_id
      elsif object.responds_to?(:file_id)
        return object.file_id
      elsif object.responds_to?(:to_i)
        return object.to_i
      end
      raise ArgumentError.new("Expected object with id or message_id, or integer, got #{object.class}")
    end

    protected def build_json_config(payload)
      {
        method:  "POST",
        headers: HTTP::Headers{"Content-Type" => "application/json", "Connection" => "keep-alive"},
        body:    payload.to_h.compact.to_json,
      }
    end

    protected def build_form_data_config(payload)
      boundary = MIME::Multipart.generate_boundary
      formdata = MIME::Multipart.build(boundary) do |form|
        payload.each do |key, value|
          attach_form_value(form, key.to_s, value)
        end
      end

      {
        method:  "POST",
        headers: HTTP::Headers{
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        body: formdata,
      }
    end

    protected def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
      return unless value
      headers = HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}"}

      case value
      when Array
        # Likely an Array(InputMedia)
        items = value.map do |item|
          if item.is_a?(InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when InputMedia
        attach_form_media(form, value)
        form.body_part(headers, value.to_json)
      when File
        filename = File.basename(value.path)
        form.body_part(
          HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
          value
        )
      else
        form.body_part(headers, value.to_s)
      end
    end

    protected def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
      media = value.media
      thumbnail = value.responds_to?(:thumbnail) ? value.thumbnail : nil

      {media: media, thumbnail: thumbnail}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(File)
          id = Random.new.random_bytes(16).hexstring
          filename = File.basename(item.path)

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumbnail)
            value.thumbnail = "attach://#{id}"
          end
        end
      end
    end

    protected def check_open_local_file(file)
      if file.is_a?(String)
        begin
          if File.file?(file)
            return File.open(file)
          end
        rescue ex
        end
      end
      file
    end

    # ░█████╗░██████╗░██╗     ███╗░░░███╗███████╗████████╗██╗░░██╗░█████╗░██████╗░░██████╗
    # ██╔══██╗██╔══██╗██║     ████╗░████║██╔════╝╚══██╔══╝██║░░██║██╔══██╗██╔══██╗██╔════╝
    # ███████║██████╔╝██║     ██╔████╔██║█████╗░░░░░██║░░░███████║██║░░██║██║░░██║╚█████╗░
    # ██╔══██║██╔═══╝░██║     ██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║██║░░██║██║░░██║░╚═══██╗
    # ██║░░██║██║░░░░░██║     ██║░╚═╝░██║███████╗░░░██║░░░██║░░██║╚█████╔╝██████╔╝██████╔╝
    # ╚═╝░░╚═╝╚═╝░░░░░╚═╝     ╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═════╝░╚═════╝░

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
      offset = 0,
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
      request(Bool, "deleteMessage", {
        chat_id:    extract_id(chat),
        message_id: extract_id(message),
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
      parse_mode : ParseMode = default_parse_mode,
      caption_entities = [] of MessageEntity,
      reply_markup = nil
    )
      if !message && !inline_message
        raise "A message_id or inline_message_id is required"
      end

      request(Bool | Message, "editMessageCaption", {
        chat_id:           extract_id(chat),
        caption:           caption,
        message_id:        extract_id(message),
        inline_message_id: extract_id(inline_message),
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

      request(Bool | Message, "editMessageReplyMarkup", {
        chat_id:           extract_id(chat),
        message_id:        extract_id(message),
        inline_message_id: extract_id(inline_message_id),
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
      parse_mode : ParseMode = default_parse_mode,
      entities = [] of MessageEntity,
      disable_link_preview = false,
      reply_markup = nil
    )
      if (!message || !chat) && !inline_message
        raise "edit_message_text requires either a chat and a message, or an inline_message"
      end

      request(Message | Bool, "editMessageText", {
        chat_id:                  extract_id(chat),
        message_id:               extract_id(message),
        inline_message_id:        extract_id(inline_message),
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
      request(Message, "forwardMessage", {
        chat_id:              extract_id(chat),
        message_thread_id:    message_thread_id,
        from_chat_id:         extract_id(from_chat_id),
        message_id:           extract_id(message_id),
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
      request(Chat, "getChat", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to get a list of administrators in a chat. On success,
    # returns an `Array` of `ChatMember` objects that contains information
    # about all chat administrators except other bots. If the chat is a
    # group or a supergroup and no administrators were appointed,
    # only the creator will be returned.
    def get_chat_administrators(chat)
      request(Array(ChatMember), "getChatAdministrators", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to get information about a member of a chat. Returns a
    # `ChatMember` object on success.
    def get_chat_member(chat, user)
      chat_member = request(ChatMember, "getChatMember", {
        chat_id: extract_id(chat),
        user_id: extract_id(user_id),
      })
    end

    # Use this method to get the number of members in a chat.
    # Returns `Int32` on success.
    def get_chat_members_count(chat)
      request(Int32, "getChatMembersCount", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user.
    # Requires no parameters.
    # Returns an Array of Sticker objects.
    def get_forum_topic_icon_stickers
      request(Array(Sticker), "getForumTopicIconStickers")
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
      request(ForumTopic, "createForumTopic", {
        chat_id:              extract_id(chat),
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
      name = nil,
      icon_custom_emoji_id = nil,
    )
      request(Bool, "editForumTopic", {
        chat_id:              extract_id(chat),
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
      request(Bool, "closeForumTopic", {
        chat_id:           extract_id(chat),
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
      request(Bool, "reopenForumTopic", {
        chat_id:           extract_id(chat),
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
      request(Bool, "deleteForumTopic", {
        chat_id:           extract_id(chat),
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
      request(Bool, "unpinAllForumTopicMessages", {
        chat_id:           extract_id(chat),
        message_thread_id: message_thread_id,
      })
    end

    # Use this method to edit the name of the 'General' topic in a forum supergroup chat. The
    # bot must be an administrator in the chat for this to work and must have
    # can_manage_topics administrator rights.
    # Returns True on success.
    def edit_general_forum_topic(
      chat,
      name
    )
      request(Bool, "editGeneralForumTopic", {
        chat_id: extract_id(chat),
        name:    name,
      })
    end

    # Use this method to close an open 'General' topic in a forum supergroup chat. The bot must
    # be an administrator in the chat for this to work and must have the
    # can_manage_topics administrator rights.
    # Returns True on success.
    def close_general_forum_topic(
      chat
    )
      request(Bool, "closeGeneralForumTopic", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to reopen a closed 'General' topic in a forum supergroup chat. The bot must be an
    # administrator in the chat for this to work and must have the can_manage_topics
    # administrator rights. The topic will be automatically unhidden if it was hidden.
    # Returns True on success.
    def reopen_general_forum_topic(
      chat
    )
      request(Bool, "reopenGeneralForumTopic", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to hide the 'General' topic in a forum supergroup chat. The bot must be
    # an administrator in the chat for this to work and must have the can_manage_topics
    # administrator rights. The topic will be automatically closed if it was open.
    # Returns True on success.
    def hide_general_forum_topic(
      chat
    )
      request(Bool, "hideGeneralForumTopic", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to unhide the 'General' topic in a forum supergroup chat. The bot must be an
    # administrator in the chat for this to work and must have the can_manage_topics
    # administrator rights.
    # Returns True on success.
    def unhide_general_forum_topic(
      chat
    )
      request(Bool, "unhideGeneralForumTopic", {
        chat_id: extract_id(chat),
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
      request(UserProfilePhotos, "getUserProfilePhotos", {
        user_id: extract_id(user_id),
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
      until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)

      request(Bool, "banChatMember", {
        chat_id:         extract_id(chat),
        user_id:         extract_id(user_id),
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
      request(Bool, "unbanChatMember", {
        chat_id:        extract_id(chat),
        user_id:        extract_id(user_id),
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
      use_independent_chat_permissions = false,
      until_date = nil
    )
      until_date = until_date.to_unix unless (until_date.is_a?(Int) || until_date.nil?)
      permissions = permissions.is_a?(NamedTuple) ? ChatPermissions.new(**permissions) : permissions

      request(Bool, "restrictChatMember", {
        chat_id:                          extract_id(chat),
        user_id:                          extract_id(user_id),
        until_date:                       until_date,
        permissions:                      permissions.to_json,
        use_independent_chat_permissions: use_independent_chat_permissions,
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
      request(Bool, "promoteChatMember", {
        chat_id:                extract_id(chat),
        user_id:                extract_id(user_id),
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
      request(Bool, "setChatPhoto", {
        chat_id: extract_id(chat),
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
      request(Bool, "deleteChatPhoto", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
    # Returns True on success.
    def set_chat_admininstrator_custom_title(chat, user, custom_title)
      request(Bool, "setChatAdministratorCustomTitle", {
        chat_id:      extract_id(chat),
        user_id:      extract_id(user_id),
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
      request(Bool, "banChatSenderChat", {
        chat_id:        extract_id(chat),
        sender_chat_id: extract_id(sender_chat_id),
      })
    end

    # Use this method to unban a previously banned channel chat in a supergroup or channel.
    # The bot must be an administrator for this to work and must have the
    # appropriate administrator rights.
    # Returns True on success.
    def unban_chat_sender_chat(chat, sender_chat)
      request(Bool, "unbanChatSenderChat", {
        chat_id:        extract_id(chat),
        sender_chat_id: extract_id(sender_chat_id),
      })
    end

    # Use this method to generate a new invite link for a chat; any previously
    # generated link is revoked. The bot must be an administrator in the chat
    # for this to work and must have the appropriate admin rights.
    # Returns the new invite link as `String` on success.
    def export_chat_invite_link(chat)
      request(String, "exportChatInviteLink", {
        chat_id: extract_id(chat),
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
      expire_date = expire_date.to_unix unless (expire_date.is_a?(Int) || expire_date.nil?)

      request(ChatInviteLink, "createChatInviteLink", {
        chat_id:              extract_id(chat),
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
      invite_link = invite_link.is_a?(String) ? invite_link : invite_link.invite_link
      expire_date = expire_date.to_unix unless (expire_date.is_a?(Int) || expire_date.nil?)

      request(ChatInviteLink, "editChatInviteLink", {
        chat_id:              extract_id(chat),
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
      invite_link = invite_link.is_a?(String) ? invite_link : invite_link.invite_link

      request(ChatInviteLink, "revokeChatInviteLink", {
        chat_id:     extract_id(chat),
        invite_link: invite_link,
      })
    end

    # Use this method to approve a chat join request. The bot must be an administrator
    # in the chat for this to work and must have the can_invite_users
    # administrator right.
    # Returns True on success.
    def approve_chat_join_request(chat, user)
      request(Bool, "approveChatJoinRequest", {
        chat_id: extract_id(chat),
        user_id: extract_id(user_id),
      })
    end

    # Use this method to decline a chat join request. The bot must be an administrator
    # in the chat for this to work and must have the can_invite_users
    # administrator right.
    # Returns True on success.
    def decline_chat_join_request(chat, user)
      request(Bool, "declineChatJoinRequest", {
        chat_id: extract_id(chat),
        user_id: extract_id(user_id),
      })
    end

    # Use this method to set default chat permissions for all members. The bot must be
    # an administrator in the group or a supergroup for this to work and must have
    # the can_restrict_members admin rights.
    # Returns True on success.
    def set_chat_permissions(
      chat,
      permissions,
      use_independent_chat_permissions = false
    )
      request(Bool, "setChatPermissions", {
        chat_id:                          extract_id(chat),
        permissions:                      permissions.to_json,
        use_independent_chat_permissions: use_independent_chat_permissions,
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
      request(Bool, "setchatTitle", {
        chat_id: extract_id(chat),
        title:   title,
      })
    end

    # Use this method to change the description of a supergroup or a channel.
    # The bot must be an administrator in the chat for this to work and
    # must have the appropriate admin rights.
    # Returns `true` on success.
    def set_chat_description(chat, description)
      request(Bool, "setchatDescription", {
        chat_id:     extract_id(chat),
        description: description,
      })
    end

    # Use this method to pin a message in a group, a supergroup, or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the `can_pin_messages` admin right in the supergroup or
    # `can_edit_messages` admin right in the channel.
    # Returns `true` on success.
    def pin_chat_message(chat, message, disable_notification = false)
      request(Bool, "pinChatMessage", {
        chat_id:              extract_id(chat),
        message_id:           extract_id(message_id),
        disable_notification: disable_notification,
      })
    end

    # Use this method to unpin a message in a group, a supergroup, or a channel.
    # The bot must be an administrator in the chat for this to work and must
    # have the ‘can_pin_messages’ admin right in the supergroup or
    # ‘can_edit_messages’ admin right in the channel.
    # Returns `true` on success.
    def unpin_chat_message(chat, message = nil)
      request(Bool, "unpinChatMessage", {
        chat_id:    extract_id(chat),
        message_id: extract_id(message_id),
      })
    end

    def unpin_all_chat_messages(chat)
      request(Bool, "unpinAllChatMessages", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method for your bot to leave a group,
    # supergroup, or channel.
    # Returns `true` on success.
    def leave_chat(chat)
      request(Bool, "leaveChat", {
        chat_id: extract_id(chat),
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
      parse_mode : ParseMode = default_parse_mode,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      request(Message, "sendAudio", {
        chat_id:                     extract_id(chat),
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
        reply_to_message_id:         extract_id(reply_to_message),
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
      thumbnail = nil,
      caption = nil,
      caption_entities = [] of MessageEntity,
      has_spoiler = false,
      parse_mode : ParseMode = default_parse_mode,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      request(Message, "sendAnimation", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        animation:                   animation,
        duration:                    duration,
        width:                       width,
        height:                      height,
        thumbnail:                   thumbnail,
        caption:                     caption,
        caption_entities:            caption_entities,
        has_spoiler:                 has_spoiler,
        parse_mode:                  parse_mode,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      action : ChatAction,
      message_thread = nil
    )
      request(Bool, "sendChatAction", {
        chat_id: extract_id(chat),
        action:  action.to_s,
        message_thread_id: extract_id(message_thread),
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
      request(Message, "sendContact", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        phone_number:                phone_number,
        first_name:                  first_name,
        last_name:                   last_name,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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

        request(Message, "sendDice", {
          chat_id:              extract_id(chat),
          message_thread_id:    message_thread_id,
          emoji:                {{ val[1] }},
          disable_notification: disable_notification,
          protect_content: protect_content,
          reply_to_message_id:  extract_id(reply_to_message),
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
      parse_mode : ParseMode = default_parse_mode,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      document = check_open_local_file(document)

      request(Message, "sendDocument", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        document:                    document,
        caption:                     caption,
        caption_entities:            caption_entities,
        parse_mode:                  parse_mode,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      request(Message, "sendLocation", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        latitude:                    latitude,
        longitude:                   longitude,
        horizontal_accuracy:         horizontal_accuracy,
        live_period:                 live_period,
        heading:                     heading,
        proximity_alert_radius:      proximity_alert_radius,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      parse_mode : ParseMode = default_parse_mode,
      entities = [] of MessageEntity,
      link_preview = false,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      request(Message, "sendMessage", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        text:                        text,
        parse_mode:                  parse_mode,
        entities:                    entities,
        disable_web_page_preview:    !link_preview,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      parse_mode : ParseMode = default_parse_mode,
      caption_entities = [] of MessageEntity,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      request("copyMessage", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        from_chat_id:                extract_id(from_chat_id),
        message_id:                  extract_id(message_id),
        caption:                     caption,
        parse_mode:                  parse_mode,
        caption_entities:            caption_entities,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      parse_mode : ParseMode = default_parse_mode,
      caption_entities = [] of MessageEntity,
      has_spoiler = false,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      photo = check_open_local_file(photo)

      request(Message, "sendPhoto", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        photo:                       photo,
        caption:                     caption,
        parse_mode:                  parse_mode,
        caption_entities:            caption_entities,
        has_spoiler:                 has_spoiler,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      media = check_open_local_file(media)

      if !message_id && !inline_message_id
        raise "Either a message or inline_message is required"
      end

      request(Message, "editMessageMedia", {
        chat_id:           extract_id(chat),
        media:             media,
        message_id:        extract_id(message_id),
        inline_message_id: extract_id(inline_message_id),
        reply_markup:      reply_markup,
      })
    end

    # Use this method to send a group of photos or videos as an album.
    # On success, an array of the sent `Messages` is returned.
    def send_media_group(
      chat,
      media : Array(InputMediaPhoto | InputMediaVideo | InputMediaAudio | InputMediaDocument),
      message_thread_id = nil,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false
    )
      request(Array(Message), "sendMediaGroup", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        media:                       media,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      request(Message, "sendVenue", {
        chat_id:                     extract_id(chat),
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
        reply_to_message_id:         extract_id(reply_to_message),
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
      has_spoiler = false,
      parse_mode : ParseMode = default_parse_mode,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      video = check_open_local_file(video)

      request(Message, "sendVideo", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        video:                       video,
        duration:                    duration,
        width:                       width,
        height:                      height,
        caption:                     caption,
        caption_entities:            caption_entities,
        has_spoiler:                 has_spoiler,
        parse_mode:                  parse_mode,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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
      parse_mode : ParseMode = default_parse_mode,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      video_note = check_open_local_file(video_note)

      request(Message, "sendVideoNote", {
        chat_id:                     extract_id(chat),
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
        reply_to_message_id:         extract_id(reply_to_message),
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

      request(Message, "sendVoice", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        voice:                       voice,
        caption:                     caption,
        caption_entities:            caption_entities,
        duration:                    duration,
        disable_notification:        disable_notification,
        protect_content:             protect_content,
        reply_to_message_id:         extract_id(reply_to_message),
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

      request(Bool | Message, "editMessageLiveLocation", {
        chat_id:                extract_id(chat),
        latitude:               latitude,
        longitude:              longitude,
        horizontal_accuracy:    horizontal_accuracy,
        live_period:            live_period,
        proximity_alert_radius: proximity_alert_radius,
        heading:                heading,
        message_id:             extract_id(message_id),
        inline_message_id:      extract_id(inline_message_id),
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

      request(Bool | Message, "stopMessageLiveLocation", {
        chat_id:           extract_id(chat),
        message_id:        extract_id(message_id),
        inline_message_id: extract_id(inline_message_id),
        reply_markup:      reply_markup ? reply_markup.to_json : nil,
      })
    end

    # Use this method to change the list of the bot's commands.
    # Returns `true` on success.
    def set_my_commands(
      commands : Array(BotCommand | NamedTuple(command: String, description: String)),
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
      request(Array(BotCommand), "getMyCommands", {
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

    # Use this method to change the bot's description, which is shown in the chat with the bot if the chat is empty.
    # Returns True on success.
    def set_my_description(description : String, language_code : String? = nil)
      request(Bool, "setMyDescription", {
        description:   description,
        language_code: language_code,
      })
    end

    # Use this method to get the current bot description for the given user language.
    # Returns BotDescription on success.
    def get_my_description(language_code : String? = nil)
      request(BotDescription, "getMyDescription", {
        language_code: language_code,
      })
    end

    # Use this method to change the bot's short description, which is shown on the bot's profile page and is sent
    # together with the link when users share the bot.
    # Returns True on success.
    def set_my_short_description(description : String, language_code : String? = nil)
      request(Bool, "setMyShortDescription", {
        description:   description,
        language_code: language_code,
      })
    end

    # Use this method to get the current bot short description for the given user language.
    # Returns BotShortDescription on success.
    def get_my_short_description(language_code : String? = nil)
      request(BotShortDescription, "getMyShortDescription", {
        language_code: language_code,
      })
    end

    # Use this method to change the bot's menu button in a private chat, or the default menu button.
    # Returns True on success.
    def set_chat_menu_button(chat, menu_button : MenuButton? = nil)
      chat_id = extract_id(chat)

      request(Bool, "setChatMenuButton", {
        chat_id:     extract_id(chat),
        menu_button: menu_button ? menu_button.to_json : nil,
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
      request(ChatAdministratorRights, "getMyDefaultAdminstratorRights", {
        for_channels: for_channels,
      })
    end

    # Use this method to set the result of an interaction with a Web App and send a corresponding
    # message on behalf of the user to the chat from which the query originated.
    # On success, a SentWebAppMessage object is returned.
    def answer_web_app_query(query_id : String, result : InlineQueryResult)
      request(SentWebAppMessage, "answerWebAppQuery", {
        web_app_query_id: query_id,
        result:           result,
      })
    end

    # Use this method to send a game.
    # On success, the sent `Message` is returned.
    def send_game(
      chat,
      game_short_name,
      message_thread_id = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil
    )
      request(Message, "sendGame", {
        chat_id:              extract_id(chat),
        message_thread_id:    message_thread_id,
        game_short_name:      game_short_name,
        disable_notification: disable_notification,
        reply_to_message_id:  extract_id(reply_to_message),
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
      request(Bool | Message, "setGameScore", {
        user_id:              extract_id(user_id),
        score:                score,
        force:                force,
        disable_edit_message: disable_edit_message,
        chat_id:              extract_id(chat),
        message_id:           extract_id(message_id),
        inline_message_id:    extract_id(inline_message_id),
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
      request(Array(GameHighScore), "getGameHighScores", {
        user_id:           extract_id(user_id),
        chat_id:           extract_id(chat),
        message_id:        extract_id(message_id),
        inline_message_id: extract_id(inline_message_id),
      })
    end

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
      errors : Array(PassportElementError)
    )
      request(Bool, "sendSticker", {
        user_id: extract_id(user_id),
        errors:  errors,
      })
    end

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
      disable_notification = false,
      reply_to_message = nil,
      reply_markup = nil
    )
      request(Message, "sendInvoice", {
        chat_id:                       extract_id(chat),
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
        reply_to_message_id:           extract_id(reply_to_message),
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
      request(Message, "answerShippingQuery", {
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

      request(Message, "sendPoll", {
        chat_id:                 extract_id(chat),
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
      request(Poll, "stopPoll", {
        chat_id:      extract_id(chat),
        message_id:   extract_id(message_id),
        reply_markup: reply_markup,
      })
    end

    # Use this method to send `.webp` stickers.
    # On success, the sent `Message` is returned.
    #
    # See: https://core.telegram.org/bots/api#stickers for more info.
    def send_sticker(
      chat,
      sticker,
      message_thread_id = nil,
      emoji = nil,
      disable_notification = false,
      protect_content = false,
      reply_to_message = nil,
      allow_sending_without_reply = false,
      reply_markup = nil
    )
      request(Message, "sendSticker", {
        chat_id:                     extract_id(chat),
        message_thread_id:           message_thread_id,
        emoji:                       emoji,
        protect_content:             protect_content,
        sticker:                     sticker,
        disable_notification:        disable_notification,
        reply_to_message_id:         extract_id(reply_to_message),
        allow_sending_without_reply: allow_sending_without_reply,
        reply_markup:                reply_markup,
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
    def set_chat_sticker_set(chat, sticker_set_name)
      request(Bool, "setChatStickerSet", {
        chat_id:          extract_id(chat),
        sticker_set_name: sticker_set_name,
      })
    end

    # Use this method to upload a .png file with a sticker for later use in
    # `#create_new_sticker_set` and `#add_sticker_to_set` methods (can be
    # used multiple times).
    # Returns the uploaded `TFile` on success.
    def upload_sticker_file(user_id, png_sticker)
      request(TFile, "uploadStickerFile", {
        user_id:     extract_id(user_id),
        png_sticker: png_sticker,
      })
    end

    # Use this method to create new sticker set owned by a user. The bot will be able to
    # edit the created sticker set. You must use exactly one of the fields `png_sticker` or `tgs_sticker`.
    # Returns `true` on success.
    def create_new_sticker_set(
      user_id,
      name,
      title,
      stickers : Array(InputSticker),
      sticker_format : Sticker::Format,
      sticker_type : Sticker::Type? = nil,
      needs_repainting = false
    )
      raise "A list of stickers are required, but none were provided" if stickers.empty?

      request(Bool, "createNewStickerSet", {
        user_id:          extract_id(user_id),
        name:             name,
        title:            title,
        stickers:         stickers,
        sticker_format:   sticker_format,
        sticker_type:     sticker_type,
        needs_repainting: needs_repainting,
      })
    end

    # Use this method to add a new sticker to a set created by the bot.
    # Returns `true` on success.
    def add_sticker_to_set(
      user_id,
      name,
      sticker
    )
      request(bool, "addStickerToSet", {
        user_id: extract_id(user_id),
        name:    name,
        sticker: sticker,
      })
    end

    # Use this method to move a sticker in a set created by the bot to a specific position.
    # Returns `true` on success.
    def set_sticker_position_in_set(sticker, position)
      request(Bool, "setStickerPositionInSet", {
        sticker:  extract_id(sticker),
        position: position,
      })
    end

    # Use this method to delete a group sticker set from a supergroup. The bot must be
    # an administrator in the chat for this to work and must have the appropriate
    # admin rights. Use the field can_set_sticker_set optionally returned in
    # `#get_chat` requests to check if the bot can use this method.
    # Returns `true` on success.
    def delete_chat_sticker_set(chat_id)
      request(Bool, "deleteChatStickerSet", {
        chat_id: extract_id(chat),
      })
    end

    # Use this method to delete a sticker from a set created by the bot.
    # Returns `true` on success.
    def delete_sticker_from_set(sticker)
      request(Bool, "deleteStickerFromSet", {
        sticker: extract_id(sticker),
      })
    end

    # Use this method to change the list of emoji assigned to a regular or custom emoji sticker.
    # The sticker must belong to a sticker set created by the bot.
    # Returns True on success.
    def set_sticker_emoji_list(sticker, emoji_list)
      request(Bool, "setStickerEmoji", {
        sticker:    extract_id(sticker),
        emoji_list: emoji_list,
      })
    end

    # Use this method to change search keywords assigned to a regular or custom emoji sticker.
    # The sticker must belong to a sticker set created by the bot.
    # Returns True on success.
    def set_sticker_keywords(sticker, keywords)
      request(Bool, "setStickerKeywords", {
        sticker:  extract_id(sticker),
        keywords: keywords,
      })
    end

    # Use this method to change the mask position of a mask sticker. The sticker must belong to a sticker set
    # that was created by the bot.
    # Returns True on success.
    def set_sticker_mask_position(sticker, position)
      request(Bool, "setStickerMaskPosition", {
        sticker:       extract_id(sticker),
        mask_position: position,
      })
    end

    # Use this method to set the title of a created sticker set.
    # Returns True on success.
    def set_sticker_set_title(name, title)
      request(Bool, "setStickerSetTitle", {
        name:  name,
        title: title,
      })
    end

    # Use this method to set the thumbnail of a sticker set. Animated thumbnails can be
    # set for animated sticker sets only.
    # Returns `true` on success.
    def set_sticker_set_thumbnail(name, user, thumbnail = nil)
      request(Bool, "setStickerSetThumbnail", {
        name:      name,
        user_id:   extract_id(user_id),
        thumbnail: thumbnail,
      })
    end

    # Use this method to set the thumbnail of a custom emoji sticker set.
    # Returns True on success.
    def set_custom_emoji_sticker_set_thumbnail(name, custom_emoji_id = nil)
      request(Bool, "setCustomEmojiStickerSetThumbnail", {
        name:            name,
        custom_emoji_id: custom_emoji_id,
      })
    end

    # Use this method to delete a sticker set that was created by the bot.
    # Returns True on success.
    def delete_sticker_set(name)
      request(Bool, "deleteStickerSet", {
        name: name,
      })
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
      request(WebhookInfo, "getWebhookInfo")
    end

    # Use this method to remove webhook integration if you decide to switch
    # back to getUpdates.
    def delete_webhook(drop_pending_updates = false)
      request(Bool, "deleteWebhook", {
        drop_pending_updates: drop_pending_updates,
      })
    end
  end
end
