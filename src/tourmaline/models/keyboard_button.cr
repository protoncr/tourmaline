module Tourmaline
  class KeyboardButton
    include JSON::Serializable

    property text : String

    property request_user : KeyboardButtonRequestUser?

    property request_chat : KeyboardButtonRequestChat?

    property request_contact : Bool?

    property request_location : Bool?

    property request_poll : KeyboardButtonPollType?

    property web_app : WebAppInfo?

    def initialize(
      @text : String,
      @request_user : KeyboardButtonRequestUser? = nil,
      @request_chat : KeyboardButtonRequestChat? = nil,
      @request_contact : Bool? = nil,
      @request_location : Bool? = nil,
      @request_poll : KeyboardButtonPollType? = nil,
      @web_app : WebAppInfo? = nil
    )
    end
  end
end
