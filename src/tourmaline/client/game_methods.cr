module Tourmaline
  class Client
    module GameMethods
      # Use this method to send a game.
      # On success, the sent `Message` is returned.
      def send_game(
        chat_id,
        game_short_name,
        message_thread_id = nil,
        disable_notification = nil,
        reply_to_message_id = nil,
        reply_markup = nil
      )
        request(Message, "sendGame", {
          chat_id:              chat_id,
          message_thread_id:    message_thread_id,
          game_short_name:      game_short_name,
          disable_notification: disable_notification,
          reply_to_message_id:  reply_to_message_id,
          reply_markup:         reply_markup,
        })
      end

      # Use this method to set the score of the specified user in a game. On success,
      # if the message was sent by the bot, returns the edited Message, otherwise
      # returns `true`.
      #
      # Raises an error, if the new score is not greater than the user's current
      # score in the chat and force is `false` (default).
      def set_game_score(
        user_id,
        score,
        force = false,
        disable_edit_message = nil,
        chat_id = nil,
        message_id = nil,
        inline_message_id = nil
      )
        request(Bool | Message, "setGameScore", {
          user_id:              user_id,
          score:                score,
          force:                force,
          disable_edit_message: disable_edit_message,
          chat_id:              chat_id,
          message_id:           message_id,
          inline_message_id:    inline_message_id,
        })
      end

      # Use this method to get data for high score tables. Will return the score of the
      # specified user and several of his neighbors in a game.
      # On success, returns an `Array` of `GameHighScore` objects.
      #
      # > This method will currently return scores for the target user, plus two of his
      # > closest neighbors on each side. Will also return the top three users if the
      # > user and his neighbors are not among them. Please note that this behavior
      # > is subject to change.
      def get_game_high_scores(
        user_id,
        chat_id = nil,
        message_id = nil,
        inline_message_id = nil
      )
        request(Array(GameHighScore), "getGameHighScores", {
          user_id:           user_id,
          chat_id:           chat_id,
          message_id:        message_id,
          inline_message_id: inline_message_id,
        })
      end
    end
  end
end
