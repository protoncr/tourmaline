module Tourmaline
  # FSM (Finite-state machine) like functionality for Tourmaline in the form of a Stage.
  # Stage allows you to create conversations/wizards which maintain their own state
  # for a particular user and/or chat.
  #
  # For an example of a stage bot, check out [examples/stage_bot.cr](https://github.com/protoncr/tourmaline/blob/master/examples/stage_bot.cr)
  class Stage(T)
    # Annotation for creating a step from a method.
    #
    # **Example:**
    # ```
    # @[Step(:foo, initial: true)]
    # def foo_step(update)
    #   ...
    # end
    # ```
    annotation Step; end

    getter client : Client

    # A hash containing the steps in this stage
    getter steps = {} of String => Proc(Client, Nil)

    # The key for the currently active step
    getter current_step : String?

    # The key to use for the initial step
    getter initial_step : String?

    # True if this Stage is currently active
    getter? active : Bool

    # Maintains a history of updates that match the given chat_id and/or user_id.
    getter update_history : Array(Update)

    # The context for this stage
    property context : T

    # The chat id that this stage applies to If nil, this stage
    # will be usable across all chats
    property! chat_id : Int::Primitive?

    # The user id that this stage applies to If nil, this stage
    # will be usable across all users
    property! user_id : Int::Primitive?

    @event_handler : EventHandler
    @on_start_handlers : Array(Proc(Nil))
    @on_exit_handlers : Array(Proc(T, Nil))
    @response_awaiter : Proc(Context, Nil)?

    forward_missing_to @client

    # Create a new Stage instance
    def initialize(@client : Tourmaline::Client,
                   *,
                   context : T,
                   chat_id = nil,
                   user_id = nil,
                   **handler_options)
      @context = context || T.new
      @chat_id = chat_id
      @user_id = user_id
      @active = false

      @update_history = [] of Update
      @on_start_handlers = [] of Proc(Nil)
      @on_exit_handlers = [] of Proc(T, Nil)

      @event_handler = UpdateHandler.new(:update, **handler_options) do |update|
        handle_update(update)
      end

      register_annotations
    end

    # Create a new Stage instance and start it immediately
    def self.enter(client, **options)
      stage = new(client, **options)
      stage.start
    end

    # Start the current Stage, setting the given initial step as the current step
    # and adding an event handler to the client.
    def start
      raise "No steps for this stage" if @steps.empty?
      @active = true
      @client.add_event_handler(@event_handler)
      @on_start_handlers.each(&.call)
      transition(@initial_step.to_s) if @initial_step
      self
    end

    # Stop the current Stage and remove the event handler from the client.
    def exit
      @active = false
      @response_awaiter = nil
      @client.remove_event_handler(@event_handler)
      @on_exit_handlers.each(&.call(@context))
      self
    end

    # Add an event handler for the given step name using the supplied block
    def on(step, initial = false, &block : Client ->)
      on(step, block, initial)
    end

    # Add an event handler for the given event name using the supplied proc
    def on(step, proc : Client ->, initial = false)
      step = step.to_s
      if initial
        Log.warn do
          "The step has already been defined as #{@initial_step} and is now being redefined " \
          "as #{step}. This is most likely unintentional."
        end if @initial_step
        @initial_step = step
      end
      @steps[step] = proc
      self
    end

    # Add a handler that's called when this Stage is started
    def on_start(&block : ->)
      @on_start_handlers << block
    end

    # Add a handler that's called when this Stage is exited
    def on_exit(&block : T ->)
      @on_exit_handlers << block
    end

    # Allows you to await a response to a step, yielding the awaited
    # update to the block.
    def await_response(&block : Context ->)
      @response_awaiter = block
    end

    # Set the current step to the given value
    def transition(event)
      event = event.to_s
      raise "Event does not exist" unless @steps.has_key?(event)
      @current_step = event
      @response_awaiter = nil
      @steps[@current_step].call(@client)
      self
    end

    private def handle_update(update)
      return unless @active

      @update_history << update

      if awaiter = @response_awaiter
        message = update.message.not_nil!

        # Ignore updates coming from this client
        return if message.from.try &.id == self.bot.id

        # If chat_id is set, check the message chat id and make sure it matches
        if @chat_id
          return unless chat_id == message.chat.id
        end

        # If user is set, check the message from user id and make sure it matches
        if @user_id
          return unless user_id == message.from.try &.id
        end

        @update_history << update

        message = update.message.not_nil!
        text = (message.text || message.caption).to_s
        ctx = Context.new(update, message, text)
        awaiter.call(ctx)
      end
    end

    private def register_annotations
      {% begin %}
        {% for method in @type.methods %}\
          {% for ann in method.annotations(Step) %}\
            %name = {{ ann[:name] || ann[0] }}
            %initial = {{ !!ann[:initial] }}
            on(%name, initial: %initial, &->{{ method.name.id }}(Client))
          {% end %}\

          {% for event_handler in Tourmaline::EventHandler.subclasses %}\
            {% if event_handler.has_constant?("ANNOTATION") %}\
              {% for ann in method.annotations(event_handler.constant("ANNOTATION").resolve) %}\
                  @client.add_event_handler({{ event_handler.id }}.new(
                    {% unless ann.args.empty? %}*{{ ann.args }}, {% end %}
                    {% unless ann.named_args.empty? %}**{{ ann.named_args }}, {% end %}
                    &->(ctx : {{ event_handler.id }}::Context) { {{ method.name.id }}(ctx); nil }
                  ))
              {% end %}\
            {% end %}\
          {% end %}\
        {% end %}\
      {% end %}
    end

    record Context, update : Update, message : Message, text : String
  end
end
