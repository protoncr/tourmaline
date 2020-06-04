require "../src/tourmaline"
require "../src/tourmaline/extra/stage"

class StageBot < Tourmaline::Client
  @[Command("start")]
  def start_command(client, update)
    if message = update.message
      # This hash will hold the answers gathered during the conversation
      initial_state = {} of String => String | Int32

      # Create an instance of our Conversation stage, and enter it for this chat. A
      # stage requires a chat_id, and can also include an optional `user_id` if
      # you want the stage to be user specific.
      stage = Conversation.enter(chat_id: message.chat.id, state: initial_state)

      # Once `stage.exit` is called, this callback will be called with the answers
      stage.on_finish do |answers|
        response = answers.map { |k, v| "#{k}: `#{v}`" }.join("\n")
        message.respond(response, parse_mode: :markdown)
      end
    end
  end

  # The conversation stage. The generic represents our context.
  class Conversation < Stage(Hash(String, String | Int32))

    # An event is a proc that takes a client. It doesn't include any update information
    # because it's not being called in response to an update.
    @[Event(:name)]
    def ask_name(client)
      client.send_message(stage.chat_id, "What is your name?")

      # Responses to events can be awaited. The next update that comes
      # in will be passed to this block.
      stage.await_response do |update|
        text = update.context["text"].as_s?
        if (message = update.message) && text
          stage.contex["name"] = text

          # `stage.transition` sets the state to the next event and calls that event
          stage.transition :age
        end
      end

      # If `stage.transition` is not called, updates will continue to be passed
      # to the `await_response` block until either `stage.transition` or `stage.exit`
      # is called.
    end

    @[Event(:age)]
    def ask_age(client)
      client.send_message(stage.chat_id, "What is your age?")
      stage.await_response do |update|
        text = update.context["text"].as_s?
        if (message = update.message) && (age = text.to_i?)
          stage.context["age"] = age
          stage.transition :gender
        end
      end
    end

    @[Event(:gender)]
    def ask_gender(client)
      valid_responses = {"male", "female", "other"}
      client.send_message(stage.chat_id, "What is your gender? (male, female, other)")
      stage.await_response do |update|
        text = update.context["text"].as_s?
        if (message = update.message) && (valid_responses.includes?(text.to_s.downcase))
          stage.context["gender"] = text.to_s

          # `stage.exit` exits the current stage, returning to the normal bot context
          stage.exit
        end
      end
    end
  end
end
