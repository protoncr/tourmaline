require "json"

module Tourmaline::Model
  class ForceReply
    FIELDS = {
      force_reply: {type: Bool, mustbe: true},
      selective:   {type: Bool, nilable: true},
    }

    JSON.mapping({{FIELDS}})
    initializer_for({{FIELDS}})
  end
end
