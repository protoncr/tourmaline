require "halite"
require "mime/multipart"

require "./error"
require "./logger"
require "./context"
require "./container"
require "./chat_action"
require "./update_action"
require "./models/*"
require "./fiber"
require "./annotations"
require "./registries/*"
require "./middleware"
require "./client/*"
require "./markup"
require "./query_result_builder"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add commands and listenters to it.
  class Client
    include Logger
    include EventRegistry
    include CommandRegistry
    include PatternRegistry
    include MiddlewareRegistry

    API_URL = "https://api.telegram.org/"

    DEFAULT_EXTENSIONS = {
      audio:      "mp3",
      photo:      "jpg",
      sticker:    "webp",
      video:      "mp4",
      animation:  "mp4",
      video_note: "mp4",
      voice:      "ogg",
    }

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot_name` to `get_me.username.to_s`.
    getter bot_name : String { get_me.username.to_s }

    property endpoint_url : String

    # Create a new instance of `Tourmaline::Client`. It is
    # highly recommended to set `@api_key` at an environment
    # variable. `@logger` can be any logger that extends
    # Crystal's built in Logger.
    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil
    )
      @endpoint_url = Path[API_URL, "bot" + @api_key].to_s
      register_commands
      register_patterns
      register_event_listeners

      Container.client = self
    end

    private def handle_update(update : Update)
      # @@logger.debug(update.to_pretty_json)
      trigger_all_middleware(update)
      trigger_commands(update)
      trigger_patterns(update)

      # Trigger events marked with the `On` annotation.
      if message = update.message
        trigger_event(UpdateAction::Message, update)

        if chat = message.chat
          trigger_event(UpdateAction::PinnedMessage, update) if chat.pinned_message
        end

        trigger_event(UpdateAction::Text, update) if message.text
        trigger_event(UpdateAction::Audio, update) if message.audio
        trigger_event(UpdateAction::Document, update) if message.document
        trigger_event(UpdateAction::Photo, update) if message.photo
        trigger_event(UpdateAction::Sticker, update) if message.sticker
        trigger_event(UpdateAction::Video, update) if message.video
        trigger_event(UpdateAction::Voice, update) if message.voice
        trigger_event(UpdateAction::Contact, update) if message.contact
        trigger_event(UpdateAction::Location, update) if message.location
        trigger_event(UpdateAction::Venue, update) if message.venue
        trigger_event(UpdateAction::NewChatMembers, update) if message.new_chat_members
        trigger_event(UpdateAction::LeftChatMember, update) if message.left_chat_member
        trigger_event(UpdateAction::NewChatTitle, update) if message.new_chat_title
        trigger_event(UpdateAction::NewChatPhoto, update) if message.new_chat_photo
        trigger_event(UpdateAction::DeleteChatPhoto, update) if message.delete_chat_photo
        trigger_event(UpdateAction::GroupChatCreated, update) if message.group_chat_created
        trigger_event(UpdateAction::MigrateToChatId, update) if message.migrate_from_chat_id
        trigger_event(UpdateAction::SupergroupChatCreated, update) if message.supergroup_chat_created
        trigger_event(UpdateAction::ChannelChatCreated, update) if message.channel_chat_created
        trigger_event(UpdateAction::MigrateFromChatId, update) if message.migrate_from_chat_id
        trigger_event(UpdateAction::Game, update) if message.game
        trigger_event(UpdateAction::VideoNote, update) if message.video_note
        trigger_event(UpdateAction::Invoice, update) if message.invoice
        trigger_event(UpdateAction::SuccessfulPayment, update) if message.successful_payment
        trigger_event(UpdateAction::ConnectedWebsite, update) if message.connected_website
        # trigger_event(UpdateAction::PassportData, update) if message.passport_data
      end

      trigger_event(UpdateAction::EditedMessage, update) if update.edited_message
      trigger_event(UpdateAction::ChannelPost, update) if update.channel_post
      trigger_event(UpdateAction::EditedChannelPost, update) if update.edited_channel_post
      trigger_event(UpdateAction::InlineQuery, update) if update.inline_query
      trigger_event(UpdateAction::ChosenInlineResult, update) if update.chosen_inline_result
      trigger_event(UpdateAction::CallbackQuery, update) if update.callback_query
      trigger_event(UpdateAction::ShippingQuery, update) if update.shipping_query
      trigger_event(UpdateAction::PreCheckoutQuery, update) if update.pre_checkout_query
      trigger_event(UpdateAction::Poll, update) if update.poll
      trigger_event(UpdateAction::PollAnswer, update) if update.poll_answer
    rescue ex
      @@logger.error("Update was not handled because: #{ex.message}")
    end

    # Sends a json request to the Telegram Client API.
    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)
      multipart = includes_media(params)

      if multipart
        config = build_form_data_config(params)
        response = Halite.request(**config, uri: method_url)
      else
        config = build_json_config(params)
        response = Halite.request(**config, uri: method_url)
      end

      result = JSON.parse(response.body)

      if res = result["result"]?
        res.to_json
      else
        handle_error(response.status_code, result["description"].as_s)
      end
    end

    # Parses the status code and returns the right error
    private def handle_error(code, message)
      case code
      when 401..403
        raise Error::Unauthorized.new(message)
      when 400
        raise Error::BadRequest.new(message)
      when 404
        raise Error::InvalidToken.new
      when 409
        raise Error::Conflict.new(message)
      when 413
        raise Error::NetworkError.new("File too large. Check telegram api limits https://core.telegram.org/bots/api#senddocument.")
      when 503
        raise Error::NetworkError.new("Bad gateway")
      else
        raise Error.new("#{message} (#{code})")
      end
    end

    private def object_or_id(object)
      if object.responds_to?(:id)
        return object.id
      end
      object
    end

    private def includes_media(params)
      params.values.any? do |val|
        case val
        when Array
          val.any? { |v| v.is_a?(::File | InputMedia) }
        when ::File, InputMedia
          true
        else
          false
        end
      end
    end

    private def build_json_config(payload)
      {
        verb:    "POST",
        headers: {"Content-Type" => "application/json", "Connection" => "keep-alive"},
        raw:     payload.to_h.compact.to_json, # TODO: Figure out why this is necessary
      }
    end

    private def build_form_data_config(payload)
      boundary = MIME::Multipart.generate_boundary
      formdata = MIME::Multipart.build(boundary) do |form|
        payload.each do |key, value|
          attach_form_value(form, key.to_s, value)
        end
      end

      {
        verb:    "POST",
        headers: {
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        raw: formdata,
      }
    end

    private def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
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
      when ::File
        filename = "#{id}.#{DEFAULT_EXTENSIONS[id]? || "dat"}"
        form.body_part(
          HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
          value
        )
      else
        form.body_part(headers, value.to_json)
      end
    end

    private def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
      media = value.media
      thumb = value.responds_to?(:thumb) ? value.thumb : nil

      {media: media, thumb: thumb}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(::File)
          pp [key, item]
          id = Random.new.random_bytes(16).hexstring
          filename = "#{id}.#{DEFAULT_EXTENSIONS[id]? || "dat"}"

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumb)
            value.thumb = "attach://#{id}"
          end
        end
      end
    end

    private def check_open_local_file(file)
      if file.is_a?(String)
        if ::File.file?(file)
          return ::File.open(file)
        end
      end
      file
    end

    # Parse mode for messages.
    enum ParseMode
      Normal
      Markdown
      MarkdownV2
      HTML
    end
  end
end
