require "logger"
require "halite"

require "./chat_action"
require "./models"
require "./fiber"
require "./command_registry"
require "./event_registry"

# require "./middleware"
# require "./handlers/command_handler"
# require "./handlers/event_handler"
# require "./handlers/middleware_handler"

require "./client/core"
require "./client/games"
require "./client/payments"
require "./client/stickers"
require "./client/webhook"

module Tourmaline
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
  # bot = Tourmaline::Bot.new(ENV["API_KEY"])
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
  # bot = Tourmaline::Bot.new(ENV["API_KEY"])
  #
  # bot.on(:inline_query) do |update|
  #   query = update.inline_query.not_nil!
  #   results = [] of Tourmaline::Model::InlineQueryResult
  #
  #   results << Tourmaline::Model::InlineQueryResultArticle.new(
  #     id: "query",
  #     title: "Inline title",
  #     input_message_content: Tourmaline::Model::InputTextMessageContent.new("Click!"),
  #     description: "Your query: #{query.query}",
  #   )
  #
  #   results << Tourmaline::Model::InlineQueryResultPhoto.new(
  #     id: "photo",
  #     caption: "Telegram logo",
  #     photo_url: "https://telegram.org/img/t_logo.png",
  #     thumb_url: "https://telegram.org/img/t_logo.png"
  #   )
  #
  #   results << Tourmaline::Model::InlineQueryResultGif.new(
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
  # bot = Tourmaline::Bot.new(ENV["API_KEY"])
  #
  # reply_markup = Tourmaline::Model::ReplyKeyboardMarkup.new([
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
  #   bot = Tourmaline::Bot.new(ENV["API_KEY"])
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
  class Bot
    include EventRegistry
    include CommandRegistry

    include Client::Core
    include Client::Webhook
    include Client::Stickers
    include Client::Payments
    include Client::Games

    API_URL = "https://api.telegram.org/"

    @logger : Logger?

    @next_offset : Int64 = 0.to_i64

    property endpoint_url : String

    getter bot_info : Model::User

    getter bot_name : String

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
      @bot_info = get_me
      @bot_name = @bot_info.username.not_nil!

      register_commands
      register_event_listeners
    end

    def handle_update(update : Model::Update)
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
      logger.error("Update was not handled because: #{ex.message}")
    end

    # Triggers an update event.
    protected def trigger_event(event : UpdateAction, update : Model::Update)
      if procs = @event_handlers[event]?
        procs.each do |proc|
          spawn proc.call(update)
        end
      end
    end

    protected def logger : Logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
    end

    # Parse mode for messages.
    enum ParseMode
      Normal
      Markdown
      HTML
    end
  end
end
