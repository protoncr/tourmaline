require "log"
require "colorize"

Log.setup_from_env(default_level: :info)

module Tourmaline
  # :nodoc:
  module Logger
    macro included
      {% begin %}
        {% tname = @type.name.stringify.split("::").map(&.underscore).join(".") %}
        Log = ::Log.for({{ tname }})
      {% end %}
    end
  end
end
