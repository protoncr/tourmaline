require "../src/tourmaline"
require "../src/tourmaline/extra/stage"

class StageBot < Tourmaline::Client
  @[Command("start")]
  def start_command(ctx)
    # This hash will hold the answers gathered during the conversation
    initial_context = {} of String => String | Int32

    # Create an instance of our Conversation stage, and enter it for this chat. A
    # stage requires a chat_id, and can also include an optional `user_id` if
    # you want the stage to be user specific.
    stage = Conversation.enter(self, chat_id: ctx.message.chat.id, context: initial_context)

    # Once `stage.exit` is called, this callback will be called with the answers
    stage.on_exit do |answers|
      ctx.message.chat.send_message(answers.to_pretty_json, parse_mode: :markdown)
    end
  end

  # The conversation stage. The generic represents our context.
  class Conversation(T) < Stage(T)
    @[Command("exit")]
    def exit_command(ctx)
      ctx.message.respond("Stopping the questions")
      self.exit
    end

    # A step is a proc that takes a client. It doesn't include any update information
    # because it's not being called in response to an update.
    #
    # Setting `initial` to true means that this will be the first step called
    # when the Stage is started.
    @[Step(:name, initial: true)]
    def ask_name(client)
      send_message(self.chat_id, "What is your name?")

      # Responses to steps can be awaited. The next update that comes
      # in will be passed to this block.
      self.await_response do |ctx|
        self.context["name"] = ctx.text

        # `self.transition` sets the state to the next step and calls the associated method
        self.transition :age
      end

      # If `self.transition` is not called, the Stage will be stuck in the current state, so
      # be sure to call `transition`, even if you're only transitioning back to the
      # same step.
    end

    @[Step(:age)]
    def ask_age(client)
      send_message(self.chat_id, "What is your age?")
      self.await_response do |ctx|
        if age = ctx.text.to_i?
          self.context["age"] = age
          self.transition :gender
        else
          send_message(self.chat_id, "Please enter a number")
          self.transition :age
        end
      end
    end

    @[Step(:gender)]
    def ask_gender(client)
      valid_responses = {"male", "female", "other"}
      send_message(self.chat_id, "What is your gender? (male, female, other)")
      self.await_response do |ctx|
        if valid_responses.includes?(ctx.text.downcase)
          self.context["gender"] = ctx.text

          # `self.exit` exits the current stage, returning to the normal bot context
          self.exit
        else
          send_message(self.chat_id, "Please send one of: male, female, or other")
          self.transition(:gender)
        end
      end
    end
  end
end

bot = StageBot.new(bot_token: ENV["API_KEY"])
bot.poll
