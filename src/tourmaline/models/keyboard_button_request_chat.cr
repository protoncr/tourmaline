module Tourmaline
  class KeyboardButtonRequestChat
    include JSON::Serializable

    property request_id : Int32

    property chat_is_channel : Bool?

    property chat_is_forum : Bool?

    property chat_has_username : Bool?

    property chat_has_is_created : Bool?

    property user_administrator_rights : ChatAdministratorRights?

    property bot_administrator_rights : ChatAdministratorRights?

    property bot_is_member : Bool?

    def initialize(
      @request_id : Int32,
      @chat_is_channel : Bool?,
      @chat_is_forum : Bool?,
      @chat_has_username : Bool?,
      @chat_has_is_created : Bool?,
      @user_administrator_rights : ChatAdministratorRights?,
      @bot_administrator_rights : ChatAdministratorRights?,
      @bot_is_member : Bool?
    )
    end
  end
end
