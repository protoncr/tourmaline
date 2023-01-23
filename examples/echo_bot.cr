require "../src/tourmaline"

@[TLA::Command("echo",
  description: "Echoes back the text you send it",
  usage: "/echo <text>",
)]
class Echo < TL::CommandController
  include AED::EventListenerInterface

  def execute
    api.reply_to message, text
  end

  @[AEDA::AsEventListener(priority: 100)]
  def on_update(event : TLE::Update)
    pp event
  end
end

TL::Config.api_token = ENV["API_TOKEN"]
TL.poll
