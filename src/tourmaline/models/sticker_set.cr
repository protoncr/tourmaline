module Tourmaline
  class StickerSet
    include JSON::Serializable
    include Tourmaline::Model

    getter name : String

    getter title : String

    getter sticker_type : Sticker::Type

    @[JSON::Field(key: "is_animated")]
    getter? animated : Bool

    @[JSON::Field(key: "is_video")]
    getter? video : Bool

    getter stickers : Array(Sticker)

    getter thumb : PhotoSize?
  end
end
