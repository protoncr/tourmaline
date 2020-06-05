require "../src/tourmaline"
require "../src/tourmaline/extra/stage"

class StageBot < Tourmaline::Client
  @[Command("start")]
  def start_command(client, update)
    message = update.message.not_nil!

    # This hash will hold the answers gathered during the conversation
    initial_context = {} of String => String | Int32

    # Create an instance of our Conversation stage, and enter it for this chat. A
    # stage requires a chat_id, and can also include an optional `user_id` if
    # you want the stage to be user specific.
    stage = Conversation.enter(client, chat_id: message.chat.id, context: initial_context)

    # Once `stage.exit` is called, this callback will be called with the answers
    stage.on_exit do |answers|
      response = answers.map { |k, v| "#{k}: `#{v}`" }.join("\n")
      send_message(message.chat.id, response, parse_mode: :markdown)
    end
  end

  # The conversation stage. The generic represents our context.
  class Conversation(T) < Stage(T)

    # A step is a proc that takes a client. It doesn't include any update information
    # because it's not being called in response to an update.
    #
    # Setting `initial` to true means that this will be the first step called
    # when the Stage is started.
    @[Step(:name, initial: true)]
    def ask_name(client)
      client.send_message(self.chat_id, "What is your name?")

      # Responses to steps can be awaited. The next update that comes
      # in will be passed to this block.
      self.await_response do |update|
        text = update.message.try &.text
        if message = update.message
          self.context["name"] = text.to_s

          # `self.transition` sets the state to the next step and calls the associated method
          self.transition :age
        end
      end

      # If `self.transition` is not called, the Stage will be stuck in the current state, so
      # be sure to call `transition`, even if you're only transitioning back to the
      # same step.
    end

    @[Step(:age)]
    def ask_age(client)
      client.send_message(self.chat_id, "What is your age?")
      self.await_response do |update|
        text = update.message.try &.text
        if (message = update.message) && (age = text.to_s.to_i?)
          self.context["age"] = age
          self.transition :gender
        end
      end
    end

    @[Step(:gender)]
    def ask_gender(client)
      valid_responses = {"male", "female", "other"}
      client.send_message(self.chat_id, "What is your gender? (male, female, other)")
      self.await_response do |update|
        text = update.message.try &.text
        if (message = update.message) && (valid_responses.includes?(text.to_s.downcase))
          self.context["gender"] = text.to_s

          # `self.exit` exits the current stage, returning to the normal bot context
          self.exit
        end
      end
    end
  end
end

bot = StageBot.new(ENV["API_KEY"])
bot.poll
