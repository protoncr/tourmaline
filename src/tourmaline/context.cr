module Tourmaline
  record Context, client : Tourmaline::Bot, update : Tourmaline::Model::Update,
      message : Tourmaline::Model::Message, command : String, text : String do
    forward_missing_to @client
  end
end
