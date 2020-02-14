require "json"
require "./input_text_message_content"
require "./input_location_message_content"
require "./input_venue_message_content"
require "./input_contact_message_content"

module Tourmaline
  alias InputMessageContent = InputTextMessageContent | InputLocationMessageContent | InputVenueMessageContent | InputContactMessageContent
end
