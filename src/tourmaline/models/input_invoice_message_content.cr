require "json"
require "./input_message_content.cr"

module Tourmaline
  class InputInvoiceMessageContent
    include JSON::Serializable
    include Tourmaline::Model

    getter title : String

    getter description : String

    getter payload : String

    getter provider_token : String

    getter currency : String

    getter prices : Array(Tourmaline::LabeledPrice)

    getter max_tip_amount : Int32?

    getter suggested_tip_amounts : Array(Int32) = [] of Int32

    getter provider_data : String?

    getter photo_url : String?

    getter photo_size : Int32?

    getter photo_width : Int32?

    getter photo_height : Int32?

    getter? need_name : Bool = false

    getter? need_phone_number : Bool = false

    getter? need_email : Bool = false

    getter? need_shipping_address : Bool = false

    getter? send_phone_number_to_provider : Bool = false

    getter? send_email_to_provider : Bool = false

    @[JSON::Field(key: "is_flexible")]
    getter? flexible : Bool = false

    def initialize(@title : String, @description : String, @payload : String, @provider_token : String, @currency : String, @prices = [] of Tourmaline::LabeledPrice, @max_tip_amount : Int32? = nil,
                   @suggested_tip_amounts : Array(Int32) = [] of Int32, @provider_data : String? = nil, @photo_url : String? = nil, @photo_size : Int32? = nil, @photo_width : Int32? = nil,
                   @photo_height : Int32? = nil, @need_name : Bool = false, @need_phone_number : Bool = false, @need_email : Bool = false, @need_shipping_address : Bool = false,
                   @send_phone_number_to_provider : Bool = false, @send_email_to_provider : Bool = false)
    end
  end
end
