require "logger"
require "halite"

require "./models"
require "./fiber"
require "./middleware"
require "./handlers/command_handler"
require "./handlers/event_handler"
require "./handlers/middleware_handler"

require "./client/core"
require "./client/games"
require "./client/payments"
require "./client/stickers"
require "./client/webhook"

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

    include Client::Core
    include Client::Webhook
    include Client::Stickers
    include Client::Payments
    include Client::Games

    API_URL = "https://api.telegram.org/"

    @logger : Logger?

    @endpoint_url : String

    @next_offset : Int64 = 0.to_i64

    getter bot_info : Model::User

    getter bot_name : String

    getter polling : Bool = false

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

    protected def load_default_middleware
      use CommandMiddleware
    end

    protected def logger : Logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
    end
  end
end
