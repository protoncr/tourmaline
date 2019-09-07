require "halite"

require "./error"
require "./logger"
require "./chat_action"
require "./update_action"
require "./models/*"
require "./fiber"
require "./annotations"
require "./command_registry"
require "./event_registry"
require "./middleware_registry"
require "./client/*"

module Tourmaline
  # The `Bot` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Bot` and add commands and listenters to it.
  class Bot
    include Logger
    include EventRegistry
    include CommandRegistry
    include MiddlewareRegistry

    API_URL = "https://api.telegram.org/"

    @bot_name : String?

    property endpoint_url : String

    # Create a new instance of `Tourmaline::Bot`. It is
    # highly recommended to set `@api_key` at an environment
    # variable. `@logger` can be any logger that extends
    # Crystal's built in Logger.
    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil
    )
      @endpoint_url = ::File.join(API_URL, "bot" + @api_key)
      register_commands
      register_event_listeners
    end

    private def handle_update(update : Model::Update)
      @@logger.debug("Update received: #{update}")

      trigger_all_middlewares(update)

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
      end

      trigger_event(UpdateAction::EditedMessage, update) if update.edited_message
      trigger_event(UpdateAction::ChannelPost, update) if update.channel_post
      trigger_event(UpdateAction::EditedChannelPost, update) if update.edited_channel_post
      trigger_event(UpdateAction::InlineQuery, update) if update.inline_query
      trigger_event(UpdateAction::ChosenInlineResult, update) if update.chosen_inline_result
      trigger_event(UpdateAction::CallbackQuery, update) if update.callback_query
      trigger_event(UpdateAction::ShippingQuery, update) if update.shipping_query
      trigger_event(UpdateAction::PreCheckoutQuery, update) if update.pre_checkout_query
    rescue ex
      @@logger.error("Update was not handled because: #{ex.message}")
    end

    # Triggers an update event.
    protected def trigger_event(event : UpdateAction, update : Model::Update)
      if procs = @event_handlers[event]?
        procs.each do |proc|
          spawn proc.call(update)
        end
      end
    end

    # Gets the name of the bot at the time the bot was
    # started. Refreshing can be done by setting
    # `@bot_name` to `get_me.username.to_s`.
    def bot_name
      @bot_name ||= get_me.username.to_s
    end

    # Sends a json request to the Telegram bot API.
    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)

      response = params.values.any?(&.is_a?(::IO::FileDescriptor)) ? Halite.post(method_url, form: params) : Halite.post(method_url, params: params)
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

    # Parse mode for messages.
    enum ParseMode
      Normal
      Markdown
      HTML
    end
  end
end
