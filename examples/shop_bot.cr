require "../src/tourmaline"

class ShopBot < Tourmaline::Client
  INVOICE = {
    title:           "Working Time Machine",
    description:     "Want to visit your great-great-great-grandparents? Make a fortune at the races? Shake hands with Hammurabi and take a stroll in the Hanging Gardens? Order our Working Time Machine today!",
    payload:         {coupon: "BLACK FRIDAY"}.to_s,
    provider_token:  ENV["PROVIDER_TOKEN"],
    start_parameter: "time-machine-sku",
    currency:        "usd",
    prices:          [
      LabeledPrice.new(label: "Working Time Machine", amount: 4200),
      LabeledPrice.new(label: "Gift Wrapping", amount: 1000),
    ],
    photo_url: "https://img.clipartfest.com/5a7f4b14461d1ab2caaa656bcee42aeb_future-me-fredo-and-pidjin-the-webcomic-time-travel-cartoon_390-240.png",
  }

  SHIPPING_OPTIONS = [
    ShippingOption.new("unicorn", "Unicorn express", [LabeledPrice.new(label: "Unicorn", amount: 2000)]),
    ShippingOption.new("slowpoke", "Slowpoke Mail", [LabeledPrice.new(label: "Unicorn", amount: 100)]),
  ]

  REPLY_MARKUP = InlineKeyboardMarkup.build do
    pay_button "💸 Buy"
    url_button "❤️", "https://github.com/watzon/tourmaline"
  end

  @[Command("start")]
  def start_command(ctx)
    ctx.message.reply_with_invoice(**INVOICE)
  end

  @[Command("buy")]
  def buy_command(ctx)
    ctx.message.reply_with_invoice(**INVOICE, reply_markup: REPLY_MARKUP)
  end

  @[On(:shipping_query)]
  def on_shipping_query(ctx)
    if query = ctx.shipping_query
      query.answer(true, shipping_options: SHIPPING_OPTIONS)
    end
  end

  @[On(:pre_checkout_query)]
  def on_pre_checkout_query(ctx)
    if query = ctx.pre_checkout_query
      query.answer(true)
    end
  end

  @[On(:successful_payment)]
  def on_successful_payment(ctx)
    puts "Wooooo"
  end
end

bot = ShopBot.new(ENV["API_KEY"])
bot.poll
