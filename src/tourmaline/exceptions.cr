require "db/pool"

module Tourmaline
  module Exceptions
    # Raised when a connection is unable to be established
    # probably due to socket/network or configuration issues.
    # It is used by the connection pool retry logic.
    class ConnectionLost < ::DB::PoolResourceLost(HTTP::Client); end

    class PoolRetryAttemptsExceeded < ::DB::PoolRetryAttemptsExceeded; end

    class Error < Exception
      ERROR_PREFIXES = ["error: ", "[error]: ", "bad request: ", "conflict: ", "not found: "]

      def initialize(message = "")
        super(clean_message(message))
      end

      def self.from_message(text)
        error = case text
                when /member list is inaccessible/
                  Exceptions::MemberListInaccessible
                when /chat not found/
                  Exceptions::ChatNotFound
                when /user not found/
                  Exceptions::UserNotFound
                when /chat_id is empty/
                  Exceptions::ChatIdIsEmpty
                when /invalid user_id specified/
                  text = "Invalid user id"
                  Exceptions::InvalidUserId
                when /chat description is not modified/
                  Exceptions::ChatDescriptionIsNotModified
                when /query is too old and response timeout expired or query id is invalid/
                  Exceptions::InvalidQueryID
                when /PEER_ID_INVALID/
                  text = "Invalid peer ID"
                  Exceptions::InvalidPeerID
                when /RESULT_ID_INVALID/
                  text = "Invalid result ID"
                  Exceptions::InvalidResultID
                when /Failed to get HTTP URL content/
                  Exceptions::InvalidHTTPUrlContent
                when /BUTTON_URL_INVALID/
                  text = "Button URL invalid"
                  Exceptions::ButtonURLInvalid
                when /URL host is empty/
                  Exceptions::URLHostIsEmpty
                when /START_PARAM_INVALID/
                  text = "Start param invalid"
                  Exceptions::StartParamInvalid
                when /BUTTON_DATA_INVALID/
                  text = "Button data invalid"
                  Exceptions::ButtonDataInvalid
                when /wrong file identifier\/HTTP URL specified/
                  Exceptions::WrongFileIdentifier
                when /group is deactivated/
                  Exceptions::GroupDeactivated
                when /Photo should be uploaded as an InputFile/
                  Exceptions::PhotoAsInputFileRequired
                when /STICKERSET_INVALID/
                  text = "Sticker set is invalid"
                  Exceptions::InvalidStickersSet
                when /there is no sticker in the request/
                  Exceptions::NoStickerInRequest
                when /CHAT_ADMIN_REQUIRED/
                  text = "Admin permissions are required"
                  Exceptions::ChatAdminRequired
                when /need administrator rights in the channel chat/
                  text = "Admin permissions are required"
                  Exceptions::NeedAdministratorRightsInTheChannel
                when /not enough rights to pin a message/
                  Exceptions::NotEnoughRightsToPinMessage
                when /method is available only for supergroups and channel/
                  Exceptions::MethodNotAvailableInPrivateChats
                when /can't demote chat creator/
                  Exceptions::CantDemoteChatCreator
                when /can't remove chat owner/
                  Exceptions::CantRemoveChatOwner
                when /can't restrict self/
                  text = "Admin can't restrict self"
                  Exceptions::CantRestrictSelf
                when /not enough rights to restrict\/unrestrict chat member/
                  Exceptions::NotEnoughRightsToRestrict
                when /not enough rights/
                  Exceptions::NotEnoughRightsOther
                when /PHOTO_INVALID_DIMENSIONS/
                  text = "Invalid photo dimensions"
                  Exceptions::PhotoDimensions
                when /supergroup members are unavailable/
                  Exceptions::UnavailableMembers
                when /type of file mismatch/
                  Exceptions::TypeOfFileMismatch
                when /wrong remote file id specified/
                  Exceptions::WrongRemoteFileIdSpecified
                when /PAYMENT_PROVIDER_INVALID/
                  text = "Payment provider invalid"
                  Exceptions::PaymentProviderInvalid
                when /currency_total_amount_invalid/
                  text = "Currency total amount invalid"
                  Exceptions::CurrencyTotalAmountInvalid
                when /HTTPS url must be provided for webhook/
                  text = "Bad webhook: HTTPS url must be provided for webhook"
                  Exceptions::WebhookRequireHTTPS
                when /Webhook can be set up only on ports 80, 88, 443 or 8443/
                  text = "Bad webhook: Webhook can be set up only on ports 80, 88, 443 or 8443"
                  Exceptions::BadWebhookPort
                when /getaddrinfo: Temporary failure in name resolution/
                  text = "Bad webhoook: getaddrinfo: Temporary failure in name resolution"
                  Exceptions::BadWebhookAddrInfo
                when /failed to resolve host: no address associated with hostname/
                  Exceptions::BadWebhookNoAddressAssociatedWithHostname
                when /can't parse URL/
                  Exceptions::CantParseUrl
                when /unsupported URL protocol/
                  Exceptions::UnsupportedUrlProtocol
                when /can't parse entities/
                  Exceptions::CantParseEntities
                when /result_id_duplicate/
                  text = "Result ID duplicate"
                  Exceptions::ResultIdDuplicate
                when /bot_domain_invalid/
                  text = "Invalid bot domain"
                  Exceptions::BotDomainInvalid
                when /Method is available only for supergroups/
                  Exceptions::MethodIsNotAvailable
                when /method not found/
                  Exceptions::MethodNotKnown
                when /terminated by other getUpdates request/
                  text = "Terminated by other getUpdates request; " \
                         "Make sure that only one bot instance is running"
                  Exceptions::TerminatedByOtherGetUpdates
                when /can't use getUpdates method while webhook is active/
                  Exceptions::CantGetUpdates
                when /bot was kicked from a chat/
                  Exceptions::BotKicked
                when /bot was blocked by the user/
                  Exceptions::BotBlocked
                when /user is deactivated/
                  Exceptions::UserDeactivated
                when /bot can't initiate conversation with a user/
                  Exceptions::CantInitiateConversation
                when /bot can't send messages to bots/
                  Exceptions::CantTalkWithBots
                when /message is not modified/
                  text = "Bad request: message is not modified " \
                         "message content and reply markup are exactly the same " \
                         "as a current content and reply markup of the message"
                  Exceptions::MessageNotModified
                when /MESSAGE_ID_INVALID/
                  Exceptions::MessageIdInvalid
                when /message to forward not found/
                  Exceptions::MessageToForwardNotFound
                when /message to delete not found/
                  Exceptions::MessageToDeleteNotFound
                when /message text is empty/
                  Exceptions::MessageTextIsEmpty
                when /message can't be edited/
                  Exceptions::MessageCantBeEdited
                when /message can't be deleted/
                  Exceptions::MessageCantBeDeleted
                when /message to edit not found/
                  Exceptions::MessageToEditNotFound
                when /reply message not found/
                  Exceptions::MessageToReplyNotFound
                when /message identifier is not specified/
                  Exceptions::MessageIdentifierNotSpecified
                when /message is too long/
                  Exceptions::MessageIsTooLong
                when /Too much messages to send as an album/
                  Exceptions::TooMuchMessages
                when /wrong live location period specified/
                  Exceptions::WrongLiveLocationPeriod
                when /The group has been migrated to a supergroup with ID (\-?\d+)/
                  match = text.match(/The group has been migrated to a supergroup with ID (\-?\d+)/)
                  id = match.not_nil![1].to_i64
                  return Exceptions::MigrateToChat.new(id)
                when /retry after (\d+)/
                  match = text.match(/retry after (\d+)/)
                  seconds = match.not_nil![1].to_i
                  return Exceptions::RetryAfter.new(seconds)
                else
                  Exceptions::Error
                end

        error.new(text)
      end

      protected def clean_message(text)
        ERROR_PREFIXES.each do |prefix|
          if text.starts_with?(prefix)
            text = text[prefix.size..]
          end
        end
        text[0].upcase + text[1..].strip
      end
    end

    class ValidationError < Error; end

    class Throttled < Error
      # TODO: Optionally handle rate limiting here
    end

    class RetryAfter < Error
      getter seconds : Int32

      def initialize(seconds)
        @seconds = seconds.to_i
        super("Flood control exceeded. Retry in #{@seconds} seconds.")
      end
    end

    class MigrateToChat < Error
      getter chat_id : Int64

      def initialize(chat_id)
        @chat_id = chat_id.to_i64
        super("The group has been migrated to a supergroup. New id: #{@chat_id}.")
      end
    end

    class BadRequest < Error; end

    class RequestTimeoutError < BadRequest; end

    class MemberListInaccessible < BadRequest; end

    class MessageError < BadRequest; end

    class MessageNotModified < MessageError; end

    class MessageIdInvalid < MessageError; end

    class MessageToForwardNotFound < MessageError; end

    class MessageToDeleteNotFound < MessageError; end

    class MessageIdentifierNotSpecified < MessageError; end

    class MessageTextIsEmpty < MessageError; end

    class MessageCantBeEdited < MessageError; end

    class MessageCantBeDeleted < MessageError; end

    class MessageToEditNotFound < MessageError; end

    class MessageToReplyNotFound < MessageError; end

    class MessageIsTooLong < MessageError; end

    class TooMuchMessages < MessageError; end

    class PollError < BadRequest; end

    class PollCantBeStopped < MessageError; end

    class PollHasAlreadyClosed < MessageError; end

    class PollsCantBeSentToPrivateChats < MessageError; end

    class MessageWithPollNotFound < MessageError; end

    class MessageIsNotAPoll < MessageError; end

    class PollSizeError < PollError; end

    class PollMustHaveMoreOptions < PollError; end

    class PollCantHaveMoreOptions < PollError; end

    class PollsOptionsLengthTooLong < PollError; end

    class PollOptionsMustBeNonEmpty < PollError; end

    class PollQuestionMustBeNonEmpty < PollError; end

    class ObjectExpectedAsReplyMarkup < BadRequest; end

    class InlineKeyboardExpected < BadRequest; end

    class ChatNotFound < BadRequest; end

    class UserNotFound < BadRequest; end

    class ChatDescriptionIsNotModified < BadRequest; end

    class InvalidQueryID < BadRequest; end

    class InvalidPeerID < BadRequest; end

    class InvalidResultID < BadRequest; end

    class InvalidHTTPUrlContent < BadRequest; end

    class ButtonURLInvalid < BadRequest; end

    class URLHostIsEmpty < BadRequest; end

    class StartParamInvalid < BadRequest; end

    class ButtonDataInvalid < BadRequest; end

    class WrongFileIdentifier < BadRequest; end

    class GroupDeactivated < BadRequest; end

    class WrongLiveLocationPeriod < BadRequest; end

    class BadWebhook < BadRequest; end

    class WebhookRequireHTTPS < BadWebhook; end

    class BadWebhookPort < BadWebhook; end

    class BadWebhookAddrInfo < BadWebhook; end

    class BadWebhookNoAddressAssociatedWithHostname < BadWebhook; end

    class NotFound < BadRequest; end

    class MethodNotKnown < NotFound; end

    class PhotoAsInputFileRequired < BadRequest; end

    class InvalidStickersSet < BadRequest; end

    class NoStickerInRequest < BadRequest; end

    class ChatAdminRequired < BadRequest; end

    class NeedAdministratorRightsInTheChannel < BadRequest; end

    class MethodNotAvailableInPrivateChats < BadRequest; end

    class CantDemoteChatCreator < BadRequest; end

    class CantRemoveChatOwner < BadRequest; end

    class CantRestrictSelf < BadRequest; end

    class NotEnoughRightsToRestrict < BadRequest; end

    class NotEnoughRightsToPinMessage < BadRequest; end

    class NotEnoughRightsOther < BadRequest; end

    class PhotoDimensions < BadRequest; end

    class UnavailableMembers < BadRequest; end

    class TypeOfFileMismatch < BadRequest; end

    class WrongRemoteFileIdSpecified < BadRequest; end

    class PaymentProviderInvalid < BadRequest; end

    class CurrencyTotalAmountInvalid < BadRequest; end

    class CantParseUrl < BadRequest; end

    class UnsupportedUrlProtocol < BadRequest; end

    class CantParseEntities < BadRequest; end

    class ResultIdDuplicate < BadRequest; end

    class MethodIsNotAvailable < BadRequest; end

    class ChatIdIsEmpty < BadRequest; end

    class InvalidUserId < BadRequest; end

    class BotDomainInvalid < BadRequest; end

    class ConflictError < Error; end

    class TerminatedByOtherGetUpdates < ConflictError; end

    class CantGetUpdates < ConflictError; end

    class Unauthorized < Error; end

    class BotKicked < Unauthorized; end

    class BotBlocked < Unauthorized; end

    class UserDeactivated < Unauthorized; end

    class CantInitiateConversation < Unauthorized; end

    class CantTalkWithBots < Unauthorized; end

    class NetworkError < Error; end
  end
end
