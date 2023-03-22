module Tourmaline
  module Helpers
    extend self

    DEFAULT_EXTENSIONS = {
      audio:      "mp3",
      photo:      "jpg",
      sticker:    "webp",
      video:      "mp4",
      animation:  "mp4",
      video_note: "mp4",
      voice:      "ogg",
    }

    # Return a random string of the given length. If `characters` is not given,
    # it will default to 0..9, a..z, A..Z.
    def random_string(length, characters = nil)
      characters ||= ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
      rands = characters.sample(length)
      rands.join
    end

    # Escape the given html for use in a Telegram message.
    def escape_html(text)
      text.to_s
        .gsub('&', "&amp;")
        .gsub('<', "&lt;")
        .gsub('>', "&gt;")
    end

    # Escape the given markdown for use in a Telegram message.
    def escape_md(text, version = 1)
      text = text.to_s

      case version
      when 0, 1
        chars = ['_', '*', '`', '[', ']', '(', ')']
      when 2
        chars = ['_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!']
      else
        raise "Invalid version #{version} for `escape_md`"
      end

      chars.each do |char|
        text = text.gsub(char, "\\#{char}")
      end

      text
    end

    # Pad the given text with spaces to make it a multiple of 4 bytes.
    def pad_utf16(text)
      String.build do |str|
        text.each_char do |c|
          str << c
          if c.ord >= 0x10000 && c.ord <= 0x10FFFF
            str << " "
          end
        end
      end
    end

    # Unpad the given text by removing spaces that were added to make it a
    # multiple of 4 bytes.
    def unpad_utf16(text)
      String.build do |str|
        last_char = nil
        text.each_char do |c|
          unless last_char && last_char.ord >= 0x10000 && last_char.ord <= 0x10FFFF
            str << c
          end
          last_char = c
        end
      end
    end

    # Convenience method to create and `Array` of `LabledPrice` from an `Array`
    # of `NamedTuple(label: String, amount: Int32)`.
    # TODO: Replace with a builder of some kind
    def labeled_prices(lp : Array(NamedTuple(label: String, amount: Int32)))
      lp.reduce([] of Tourmaline::LabeledPrice) { |acc, i|
        acc << Tourmaline::LabeledPrice.new(label: i[:label], amount: i[:amount])
      }
    end

    # Convenience method to create an `Array` of `ShippingOption` from a
    # `NamedTuple(id: String, title: String, prices: Array(LabeledPrice))`.
    # TODO: Replace with a builder of some kind
    def shipping_options(options : Array(NamedTuple(id: String, title: String, prices: Array(LabeledPrice))))
      lp.reduce([] of Tourmaline::ShippingOption) { |acc, i|
        acc << Tourmaline::ShippingOption.new(id: i[:id], title: i[:title], prices: i[:prices])
      }
    end
  end
end
