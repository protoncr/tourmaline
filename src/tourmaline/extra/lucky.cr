class Tourmaline::LuckyBotHandler(T)
  include HTTP::Handler

  @path : String

  def initialize(
    @bot : T,
    @url : String,
    path : String? = nil,
    certificate = nil,
    max_connections = nil
  )
    {% unless T <= Tourmaline::Client %}
      {% raise "bot must be an instance of Tourmaline::Client" %}
    {% end %}

    @path = path || "/webhook/#{@bot.bot.username}"

    check_config
    set_webhook(certificate, max_connections)
  end

  def call(ctx : HTTP::Server::Context)
    case ctx.request.path
    when @path
      if ctx.request.method == "POST"
        if body = ctx.request.body
          update = Tourmaline::Update.from_json(body)
          @bot.handle_update(update)
        end
      end
    else
      call_next(ctx)
    end
  end

  private def check_config
    raise "Tourmaline bot webhooks require ssl." unless @url.starts_with?("https")

    ["10.", "172.", "192.", "100."].each do |ippart|
      raise "Cannot serve a Tourmaline bot webhook locally. Please use Ngrok for local testing." if @url.starts_with?(ippart)
    end
  end

  private def set_webhook(certificate = nil, max_connections = nil)
    webhook_path = File.join(@url, @path)
    @bot.set_webhook(webhook_path, certificate, max_connections)
  end

  private def unset_webhook
    @bot.unset_webhook
  end
end
