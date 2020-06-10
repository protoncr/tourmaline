require "log"
require "colorize"

module Tourmaline
  module Logger
    macro included
      {% begin %}
        {% tname = @type.name.stringify.split("::").map(&.underscore).join(".") %}
        Log = ::Log.for({{ tname }})
      {% end %}
    end

    Backend = ::Log::IOBackend.new.tap do |l|
      l.formatter = Tourmaline::Logger::Formatter
    end

    struct Formatter
      extend Log::Formatter

      class_property colors = {
        none:    {:white, nil},
        fatal:   {:red, :bold},
        error:   {:red, nil},
        warn:    {:yellow, nil},
        warning: {:yellow, nil},
        info:    {:cyan, nil},
        notice:  {:cyan, :underline},
        debug:   {:green, nil},
        trace:   {:green, :bold}
      }

      def initialize(@entry : Log::Entry, @io : IO)
      end

      def self.format(entry, io)
        new(entry, io).run
      end

      def run
        severity = @entry.severity
        level = "[" + ("%-7s" % severity.to_s) + "]"
        source = "[" + ("%-10s" % @entry.source) + "]"
        @io << color_message("#{level} #{source} - #{@entry.message}", severity)
      end

      private def color_message(message, level)
        {% begin %}
          color, decoration = case level
            {% for const in ::Log::Severity.constants %}
              in ::Log::Severity::{{ const.id }}
                @@colors[{{ const.id.stringify.downcase.id.symbolize }}]
            {% end %}
          end

          colored = message.colorize.fore(color)
          colored = colored.colorize.mode(decoration) if decoration
          colored
        {% end %}
      end
    end
  end
end
