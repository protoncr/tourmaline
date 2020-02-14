require "json"

module Tourmaline
  abstract class InlineQueryResult
    include JSON::Serializable
  end
end
