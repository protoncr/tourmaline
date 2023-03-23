require "../src/tourmaline"
require "../src/tourmaline/extra/paginated_keyboard"

client = Tourmaline::Client.new(ENV["BOT_TOKEN"])

start_command = Tourmaline::CommandHandler.new(:start) do |ctx|
  results = ('a'..'z').to_a.map(&.to_s)

  PaginatedKeyboard.new(
    ctx,
    results: results,
    per_page: 5,
    prefix: "{index}. ",
    footer: "\nPage: {page} of {page count}"
  ).send
end

client.register(start_command)

client.poll
