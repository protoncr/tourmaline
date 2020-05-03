require "log"
require "colorize"

verbose = ENV["VERBOSE"]?.try &.downcase == "true"
Log.builder.bind "*", :warning, Log::IOBackend.new
Log.builder.bind("tourmaline.client.*",
                 verbose ? Log::Severity::Debug : Log::Severity::Info,
                 Tourmaline::Logger::LOG_BACKEND)

module Tourmaline
  # :nodoc:
  module Logger
    macro included
      Log = ::Log.for(self)
    end

    LOG_BACKEND = ::Log::IOBackend.new.tap do |l|
      l.formatter = Logger::FORMATTER
    end

    FORMATTER = ->(entry : ::Log::Entry, io : IO) {
      severity = entry.severity
      level = "[" + ("%-7s" % severity.to_s) + "]"
      source = "[" + ("%-10s" % entry.source) + "]"
      io << color_message("#{level} #{source} - #{entry.message}", severity)
    }

    private class_property colors = {
      none:    :white,
      fatal:   :light_red,
      error:   :red,
      warning: :yellow,
      info:    :blue,
      verbose: :cyan,
      debug:   :green,
    }

    private def self.color_message(message, level)
      {% for const in ::Log::Severity.constants %}
        if level == ::Log::Severity::{{ const.id }}
          return message.colorize(self.colors[{{ const.id.stringify.downcase.id.symbolize }}])
        end
      {% end %}
    end
  end
end
