require "log"
require "colorize"

severity = Log::Severity.parse(ENV["LOG"]? || "Info")
Log.builder.bind("tourmaline.client.*", severity, Tourmaline::Logger::LOG_BACKEND)

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
