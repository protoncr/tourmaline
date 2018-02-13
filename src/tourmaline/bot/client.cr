require "logger"
require "halite"

require "./types"

module Tourmaline::Bot

  enum ParseMode
    Normal
    Markdown
    HTML
  end

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

  class Client

    API_URL = "https://api.telegram.org/"

    @logger : Logger?

    @endpoint_url : String

    @bot_info : User

    @bot_name : String

    @polling : Bool = false

    @next_offset : Int64 = 0.to_i64

    @middlewares = [] of Update ->

    @commands = {} of String => (Message ->) | (Message, Array(String) ->)

    @event_handlers = {} of String => Update ->

    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil)
      @endpoint_url = ::File.join(API_URL, "bot" + @api_key)
      @bot_info = get_me
      @bot_name = @bot_info.username.not_nil!

      add_command_handler
    end

    def command(names : String | Array(String), &block : Message ->)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          @commands[name] = block
        end
      else
        names = names[1..-1] if names[0] == "/"
        @commands[names] = block
      end
    end

    def command(names : String | Array(String), &block : Message, Array(String) ->)
      if names.is_a?(Array)
        names.each do |name|
          name = name[1..-1] if name[0] == "/"
          @commands[name] = block
        end
      else
        names = names[1..-1] if names[0] == "/"
        @commands[names] = block
      end
    end

    def remove_command(name : String)
      @@commands.delete_if { |n| n == name }
    end

    def call(cmd : String, message : Message, params : Array(String))
      if proc = @commands[cmd]?
        if proc.is_a?(Message ->)
          proc.call(message)
        else
          proc.call(message, params)
        end
      else
        raise "The command `#{cmd}` doesn't exist"
      end
    end

    def use(middleware : Update ->)
      @middlewares.push middleware
    end

    def use(&block : Update ->)
      @middlewares.push block
    end

    def is_admin?(chat_id)
      admins = get_chat_administrators(chat_id)
      admins.any? { |a| a.user.id = @bot_info.id }
    end

    def on(actions : UpdateAction | Array(UpdateAction), &block : Update ->)
      actions = [ actions ] unless UpdateAction.is_a?(Array)
      actions.as(Array(UpdateAction)).each do |action|
        @event_handlers[action.to_s] = block
      end
    end

    def poll
      @polling = true

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

    def stop_polling
      @polling = false
    end

    def handle_update(update)
      @middlewares.each { |m| m.call(update) }

      case update
      when .message
        trigger(UpdateAction::Message, update)
      when .edited_message
        trigger(UpdateAction::EditedMessage, update)
      when .channel_post
        trigger(UpdateAction::ChannelPost, update)
      when .edited_channel_post
        trigger(UpdateAction::EditedChannelPost, update)
      when .inline_query
        trigger(UpdateAction::InlineQuery, update)
      when .chosen_inline_result
        trigger(UpdateAction::ChosenInlineResult, update)
      when .callback_query
        trigger(UpdateAction::CallbackQuery, update)
      when .shipping_query
        trigger(UpdateAction::ShippingQuery, update)
      when .pre_checkout_query
        trigger(UpdateAction::PreCheckoutQuery, update)
      end
    rescue ex
      logger.error("Update was not handled because: #{ex.message}")
    end

    def trigger(event : UpdateAction, update : Update)
      if @event_handlers.has_key?(event.to_s)
        proc = @event_handlers[event.to_s]
        proc.call(update)
      end
    end

    def get_me
      response = request("getMe")
      User.from_json(response)
    end

    def get_updates(
      offset = @next_offset,
      limit = nil,
      timeout = @updates_timeout,
      allowed_updates = @allowed_updates)

      response = request("getUpdates", {
        offset: offset,
        limit: limit,
        timeout: timeout,
        allowed_updates: allowed_updates
      })

      updates = Array(Update).from_json(response)

      if !updates.empty?
        @next_offset = updates.last.update_id + 1
      end

      updates
    end

    def answer_callback_query(
      callback_query_id,
      text = nil,
      show_alert = nil,
      url = nil,
      cache_time = nil)

      response = request("answerCallbackQuery", {
        callback_query_id: callback_query_id,
        text: text,
        show_alert: show_alert,
        url: url,
        cache_time: cache_time
      })

      response == "true"
    end

    def answer_inline_query(
      inline_query_id,
      results,
      cache_time = nil,
      is_personal = nil,
      next_offset = nil,
      switch_pm_text = nil,
      switch_pm_parameter = nil)

      response = request("answerInlineQuery", {
        inline_query_id: inline_query_id,
        results: results.to_json,
        cache_time: cache_time,
        is_personal: is_personal,
        next_offset: next_offset,
        switch_pm_text: switch_pm_text,
        switch_pm_parameter: switch_pm_parameter
      })

      response == "true"
    end

    def delete_message(chat_id, message_id)

      response = request("deleteMessage", {
        chat_id: chat_id,
        message_id: message_id
      })

      puts response

      response == "true"
    end

    def edit_message_caption(
      chat_id,
      caption,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil)

      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("editMesasageCaption", {
        chat_id: chat_id,
        caption: caption,
        message_id: message_id,
        inline_message_id: inline_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      response.is_a?(String) ?
        response == "true" :
        Message.from_json(response)
    end

    def edit_message_reply_markup(
      chat_id,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil)

      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("editMesasageReplyMarkup", {
        chat_id: chat_id,
        message_id: message_id,
        inline_message_id: inline_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      response.is_a?(String) ?
        response == "true" :
        Message.from_json(response)
    end

    def edit_message_text(
      chat_id,
      text,
      message_id = nil,
      inline_message_id = nil,
      parse_mode = ParseMode::Normal,
      disable_link_preview = false,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("editMessageText", {
        chat_id: chat_id,
        message_id: message_id,
        inline_message_id: inline_message_id,
        text: text,
        parse_mode: parse_mode,
        disable_web_page_preview: disable_link_preview,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def forward_message(
      chat_id,
      from_chat_id,
      message_id,
      disable_notification = false)

      response = request("forwardMessage", {
        chat_id: chat_id,
        from_chat_id: from_chat_id,
        message_id: message_id,
        disable_notification: disable_notification
      })

      Message.from_json(response)
    end

    def get_chat(chat_id)

      response = request("getChat", {
        chat_id: chat_id
      })

      Chat.from_json(response)
    end

    def get_chat_administrators(chat_id)

      response = request("getChatAdministrators", {
        chat_id: chat_id
      })

      Array(ChatMember).from_json(response)
    end

    def get_chat_member

    end

    def get_chat_members_count

    end

    def get_file(file_id)

      response = request("getFile", {
        file_id: file_id
      })

      File.from_json(response)
    end

    def get_file_link(file)

      if file.file_path
        return File.join(@endpoint_url, file.file_path)
      end

      nil
    end

    def get_user_profile_photos(
      user_id,
      offset = nil,
      limit = nil)

      response = request("getUserProfilePhotos", {
        user_id: user_id,
        offset: offset,
        limit: limit
      })

      UserProfilePhotos.from_json(response)
    end

    def kick_chat_member(
      chat_id,
      user_id,
      until_date = nil)

      response = request("kickChatMember", {
        chat_id: chat_id,
        user_id: user_id,
        until_date: until_date
      })

      response == "true"
    end

    def unban_chat_member(
      chat_id,
      user_id)

      response = request("unbanChatMember", {
        chat_id: chat_id,
        user_id: user_id
      })

      response == "true"
    end

    def restrict_chat_member(
      chat_id,
      user_id,
      until_date = nil,
      can_see_messages = nil,
      can_send_media_messages = nil,
      can_send_other_messages = nil,
      can_add_web_page_previews = nil)

      response = request("restrictChatMember", {
        chat_id: chat_id,
        user_id: user_id,
        until_date: until_date,
        can_see_messages: can_see_messages,
        can_send_media_messages: can_send_media_messages,
        can_send_other_messages: can_send_other_messages,
        can_add_web_page_previews: can_add_web_page_previews
      })

      response == "true"
    end

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
      can_promote_members = nil)

      response = request("promoteChatMember", {
        chat_id: chat_id,
        user_id: user_id,
        until_date: until_date,
        can_change_info: can_change_info,
        can_post_messages: can_post_messages,
        can_edit_messages: can_edit_messages,
        can_delete_messages: can_delete_messages,
        can_invite_users: can_invite_users,
        can_restrict_members: can_restrict_members,
        can_pin_messages: can_pin_messages,
        can_promote_members: can_promote_members
      })

      response == "true"
    end

    def export_chat_invite_link(chat_id)

      response = request("exportChatInviteLink", {
        chat_id: chat_id
      })

      response.to_s
    end

    def set_chat_photo(chat_id, photo)

      response = request("setChatPhoto", {
        chat_id: chat_id,
        photo: photo
      })

      response == "true"
    end

    def delete_chat_photo(chat_id)

      response = request("deleteChatPhoto", {
        chat_id: chat_id
      })

      response == "true"
    end

    def set_chat_title(chat_id, title)

      response = request("setchatTitle", {
        chat_id: chat_id,
        title: title
      })

      response == "true"
    end

    def set_chat_description(chat_id, description)

      response = request("setchatDescription", {
        chat_id: chat_id,
        description: description
      })

      response == "true"
    end

    def pin_chat_message(chat_id, message_id, disable_notification = false)

      response = request("pinChatMessage", {
        chat_id: chat_id,
        message_id: message_id,
        disable_notification: disable_notification
      })

      response == "true"
    end

    def unpin_chat_message(chat_id)

      response = request("unpinChatMessage", {
        chat_id: chat_id
      })

      response == "true"
    end

    def leave_chat(chat_id)

      response = request("leaveChat", {
        chat_id: chat_id
      })

      Chat.from_json(response)
    end

    def delete_webhook

    end

    def send_audio(
      chat_id,
      audio,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendAudio", {
        chat_id: chat_id,
        audio: audio,
        caption: caption,
        duration: duration,
        preformer: preformer,
        title: title,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_chat_action(
      chat_id,
      action : ChatAction)

      response = request("sendChatAction", {
        chat_id: chat_id,
        action: action.to_s
      })

      response == "true"
    end

    def send_contact(
      chat_id,
      phone_number,
      first_name,
      last_name = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendContact", {
        chat_id: chat_id,
        phone_number: phone_number,
        first_name: first_name,
        last_name: last_name,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_document(
      chat_id,
      document,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendDocument", {
        chat_id: chat_id,
        document: document,
        caption: caption,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_location(
      chat_id,
      latitude,
      longitude,
      live_period = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendLocation", {
        chat_id: chat_id,
        latitude: latitude,
        longitude: longitude,
        live_period: live_period,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_message(
      chat_id,
      text,
      parse_mode = ParseMode::Normal,
      disable_link_preview = false,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      parse_mode = parse_mode == ParseMode::Normal ? nil : parse_mode.to_s

      response = request("sendMessage", {
        chat_id: chat_id,
        text: text,
        parse_mode: parse_mode,
        disable_web_page_preview: disable_link_preview,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_photo(
      chat_id,
      photo,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendPhoto", {
        chat_id: chat_id,
        photo: photo,
        caption: caption,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    # Not working yet
    def send_media_group(
      chat_id,
      media,
      disable_notification = false,
      reply_to_message_id = nil)

      response = request("sendMediaGroup", {
        chat_id: chat_id,
        media: media,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id
      })

      Message.from_json(response)
    end

    def send_venue(
      chat_id,
      latitude,
      longitude,
      title,
      address,
      foursquare_id = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendVenue", {
        chat_id: chat_id,
        latitude: latitude,
        longitude: longitude,
        title: title,
        address: address,
        foursquare_id: foursquare_id,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_video(
      chat_id,
      video,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendVideo", {
        chat_id: chat_id,
        video: video,
        duration: duration,
        width: width,
        height: height,
        caption: caption,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_video_note(
      chat_id,
      video_note,
      duration = nil,
      width = nil,
      height = nil,
      caption = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendVideoNote", {
        chat_id: chat_id,
        video_note: video_note,
        duration: duration,
        width: width,
        height: height,
        caption: caption,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def send_voice(
      chat_id,
      voice,
      caption = nil,
      duration = nil,
      preformer = nil,
      title = nil,
      disable_notification = false,
      reply_to_message_id = nil,
      reply_markup = nil)

      response = request("sendVoice", {
        chat_id: chat_id,
        voice: voice,
        caption: caption,
        duration: duration,
        disable_notification: disable_notification,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def edit_message_live_location(
      chat_id,
      latitude,
      longitude,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil)

      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("editMessageLiveLocation", {
        chat_id: chat_id,
        latitude: latitude,
        longitude: longitude,
        message_id: message_id,
        inline_message_id: inline_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    def stop_message_live_location(
      chat_id,
      message_id = nil,
      inline_message_id = nil,
      reply_markup = nil)

      if !message_id && !inline_message_id
        raise "A message_id or inline_message_id is required"
      end

      response = request("stopMessageLiveLocation", {
        chat_id: chat_id,
        message_id: message_id,
        inline_message_id: inline_message_id,
        reply_markup: reply_markup ? reply_markup.to_json : nil
      })

      Message.from_json(response)
    end

    ##########################
    #        WEBHOOK         #
    ##########################

    def set_webhook

    end

    def get_webhook_info

    end

    ##########################
    #        STICKERS        #
    ##########################

    def send_sticker

    end

    def get_sticker_set

    end

    def set_chat_sticker_set

    end

    def add_sticker_to_set

    end

    def create_new_sticker_set

    end

    def delete_chat_sticker_set

    end

    def delete_sticker_from_set

    end

    def send_sticker_position_in_set

    end

    def upload_sticker_file

    end

    ##########################
    #        PAYMENTS        #
    ##########################

    def send_invoice

    end

    def answer_shipping_query

    end

    def answer_pre_checkout_query

    end

    ##########################
    #         GAMES          #
    ##########################

    def send_game

    end

    def answer_game_query

    end

    def set_game_score

    end

    def get_game_high_scores

    end

    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)

      response = params.values.any?(&.is_a?(::IO::FileDescriptor)) ?
        Halite.post(method_url, form: params) :
        Halite.post(method_url, params: params)

      result = JSON.parse(response.body)

      if result = result["result"]?
        return result.to_json
      else
        raise "Something went wrong: #{result}"
      end
    end

    private def add_command_handler
      use do |update|
        if message = update.message
          if entities = message.entities
            entities.each do |entity|
              if entity.type == "bot_command" && entity.offset == 0
                message_text = message.text.not_nil!

                # Get the command value
                command_name = message_text[1..entity.length - 1]

                # Check if the command has the bot's name attached
                if command_name.includes?("@")
                  pieces = command_name.split("@")
                  if pieces[1] != @bot_name
                    next
                  end

                  command_name = pieces[0]
                end

                # Check the command against the commands hash
                if @commands.has_key?(command_name)
                  command = @commands[command_name]

                  if command.is_a?(Message ->)
                    command.call(message)
                  else
                    rest = message_text[entity.length..-1]
                    params = rest.split(" ")
                    command.call(message, params)
                  end
                end
              end
            end
          end
        end
      end
    end

    protected def logger : Logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
    end
  end
end
