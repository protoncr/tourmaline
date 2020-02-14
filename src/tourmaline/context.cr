module Tourmaline
  record Context, client : Tourmaline::Bot, update : Tourmaline::Update,
      message : Tourmaline::Message, command : String, text : String do
    forward_missing_to @client
  end
end
