module Tourmaline
  class Chat
    def name
      if first_name || last_name
        [first_name, last_name].compact.join(" ")
      else
        title.to_s
      end
    end

    def supergroup?
      type == Type::Supergroup
    end

    def private?
      type == Type::Private
    end

    def group?
      type == Type::Group
    end

    def channel?
      type == Type::Channel
    end

    enum Type
      Private
      Group
      Supergroup
      Channel

      def self.new(pull : JSON::PullParser)
        parse(pull.read_string)
      end

      def to_json(json : JSON::Builder)
        json.string(to_s)
      end
    end
  end
end
