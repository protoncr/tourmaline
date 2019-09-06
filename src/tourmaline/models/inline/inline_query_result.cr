require "json"

module Tourmaline::Model
  abstract class InlineQueryResult
    include JSON::Serializable
  end
end
