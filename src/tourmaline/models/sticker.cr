module Tourmaline
  class Sticker
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter type : Type

    getter width : Int32

    getter height : Int32

    @[JSON::Field(key: "is_animated")]
    getter? animated : Bool

    @[JSON::Field(key: "is_video")]
    getter? video : Bool

    getter thumb : PhotoSize?

    getter emoji : String?

    getter set_name : String?

    getter premium_animation : TFile?

    getter mask_position : MaskPosition?

    getter custom_emoji_id : String?

    getter file_size : Int32?

    enum Type
      Regular
      Mask
      CustomEmoji

      def self.new(pull : JSON::PullParser)
        parse(pull.read_string.camelcase)
      end

      def to_json(json : JSON::Builder)
        json.string(to_s.underscore)
      end
    end
  end
end
