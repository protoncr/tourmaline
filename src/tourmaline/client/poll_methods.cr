module Tourmaline
  class Client
    module PollMethods
      # Use this method to send a native poll.
      # On success, the sent Message is returned.
      def send_poll(
        chat,
        question : String,
        options : Array(String), # 2-10 strings, up to 100 chars each
        anonymous : Bool = true,
        type : Poll::Type = Poll::Type::Regular,
        allows_multiple_answers : Bool = false,
        correct_option_id : Int32? = nil, # required for quiz mode
        close_date : Time? = nil,
        open_period : Int32? = nil,
        closed : Bool = false,
        disable_notification : Bool = false,
        reply_to_message = nil,
        reply_markup = nil
      )
        if options.size < 2 || options.size > 10
          raise "Incorrect option count. Expected 2-10, given #{options.size}."
        end

        if options.any? { |o| o.size < 1 || o.size > 300 }
          raise "Incorrect option size. Poll options must be between 1 and 300 characters."
        end

        if type == Poll::Type::Quiz && !correct_option_id
          raise "Quiz poll type requires a correct_option_id be set."
        end

        chat_id = chat.is_a?(Int) ? chat : chat.id
        if reply_to_message
          reply_to_message = reply_to_message.is_a?(Int) ? reply_to_message : reply_to_message.message_id
        end

        request(Message, "sendPoll", {
          chat_id:                 chat_id,
          question:                question,
          options:                 options,
          anonymous:               anonymous,
          type:                    type.to_s,
          allows_multiple_answers: allows_multiple_answers,
          correct_option_id:       correct_option_id,
          close_date:              close_date.try &.to_unix,
          is_closed:               closed,
          disable_notification:    disable_notification,
          reply_to_message_id:     reply_to_message,
          reply_markup:            reply_markup,
        })
      end

      # Use this method to stop a poll which was sent by the bot.
      # On success, the stopped `Poll` with the final results is returned.
      def stop_poll(
        chat,
        message,
        reply_markup = nil
      )
        chat_id = chat.is_a?(Int) ? chat : chat.id
        message_id = message.is_a?(Int) ? message : message.message_id

        request(Poll, "stopPoll", {
          chat_id:      chat_id,
          message_id:   message_id,
          reply_markup: reply_markup,
        })
      end
    end
  end
end
