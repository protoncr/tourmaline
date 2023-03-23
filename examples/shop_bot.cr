require "../src/tourmaline"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

INVOICE = {
  title:           "Working Time Machine",
  description:     "Want to visit your great-great-great-grandparents? Make a fortune at the races? Shake hands with Hammurabi and take a stroll in the Hanging Gardens? Order our Working Time Machine today!",
  payload:         {coupon: "BLACK FRIDAY"}.to_s,
  provider_token:  ENV["PROVIDER_TOKEN"],
  start_parameter: "time-machine-sku",
  currency:        "usd",
  prices:          [
    Tourmaline::LabeledPrice.new(label: "Working Time Machine", amount: 4200),
    Tourmaline::LabeledPrice.new(label: "Gift Wrapping", amount: 1000),
  ],
  photo_url: "https://img.clipartfest.com/5a7f4b14461d1ab2caaa656bcee42aeb_future-me-fredo-and-pidjin-the-webcomic-time-travel-cartoon_390-240.png",
}

SHIPPING_OPTIONS = [
Tourmaline::ShippingOption.new("unicorn", "Unicorn express", [Tourmaline::LabeledPrice.new(label: "Unicorn", amount: 2000)]),
Tourmaline::ShippingOption.new("slowpoke", "Slowpoke Mail", [Tourmaline::LabeledPrice.new(label: "Unicorn", amount: 100)]),
]

REPLY_MARKUP = Tourmaline::InlineKeyboardMarkup.build do
  pay_button "💸 Buy"
  url_button "❤️", "https://github.com/watzon/tourmaline"
end

start_command = Tourmaline::CommandHandler.new("start") do |ctx|
  ctx.reply_with_invoice(**INVOICE)
end

buy_command = Tourmaline::CommandHandler.new("buy") do |ctx|
  ctx.reply_with_invoice(**INVOICE.merge({ reply_markup: REPLY_MARKUP }))
end

client.register(start_command, buy_command)

client.on(:shipping_query) do |ctx|
  ctx.answer_query(true, shipping_options: SHIPPING_OPTIONS)
end

client.on(:pre_checkout_query) do |ctx|
  query.answer(true)
end

client.on(:successful_payment) do |ctx|
  ctx.reply("Thank you for your purchase!")
end

client.poll
