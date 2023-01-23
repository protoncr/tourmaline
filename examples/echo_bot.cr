require "../src/tourmaline"

class Echo < TL::Controller
  @[TLA::Command("echo")]
  def echo_command(message : TLM::Message)
    api.reply_to(message, message.text)
  end
end

TL::Config.api_token = ENV["API_TOKEN"]
TL.poll
