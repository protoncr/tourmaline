module Tourmaline
  module PatternRegistry
    getter patterns = {} of Regex => Int32
    getter procs = [] of Proc(Message, Nil)

    private def register_patterns
      {% begin %}
        {% for command_class in Tourmaline::Bot.subclasses %}
          {% for method in command_class.methods %}
            {% if ann = (method.annotation(Hears) || method.annotation(Tourmaline::Hears)) %}
              %proc = ->(message : Message){ {{method.name.id}}(message); nil }
              hears({{ ann[0] }}, %proc)
            {% end %}
          {% end %}
        {% end %}
        on(:message, ->trigger_patterns(Update))
      {% end %}
    end

    def hears(patterns : String | Regex | Array(String | Regex), &block : Message ->)
      hears(patterns, block)
    end

    def hears(patterns : String | Regex | Array(String | Regex), proc : Message ->)
      procs.push(proc)
      proc_idx = procs.size - 1

      patterns = [patterns] unless patterns.is_a?(Array)
      patterns.each do |pattern|
        case pattern
        when Regex
          @patterns[pattern] = proc_idx
        when String
          pattern = Regex.new(pattern)
          @patterns[pattern] = proc_idx
        end
      end
    end

    private def trigger_patterns(update : Update)
      if message = update.message
        if message_text = message.text
          patterns.each do |(pattern, proc_idx)|
            spawn do
              if pattern =~ message_text.to_s
                procs[proc_idx].call(message.not_nil!)
              end
            end
          end
        end
      end

      nil
    end
  end
end
