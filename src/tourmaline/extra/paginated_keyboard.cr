module Tourmaline
  # Convenience class for creating an `InlineKeyboard` with built in pagination.
  # It is designed to be customizable so as not to get in your way.
  class PaginatedKeyboard < InlineKeyboardMarkup
    @client : Tourmaline::Client

    @[JSON::Field(ignore: true)]
    @current_page : Int32

    @[JSON::Field(ignore: true)]
    getter id : String

    @[JSON::Field(ignore: true)]
    property results : Array(String)

    @[JSON::Field(ignore: true)]
    property per_page : Int32

    @[JSON::Field(ignore: true)]
    property header : String?

    @[JSON::Field(ignore: true)]
    property footer : String?

    @[JSON::Field(ignore: true)]
    property prefix : String?

    @[JSON::Field(ignore: true)]
    property back_button_procs : Array(Proc(PaginatedKeyboard, Nil))

    @[JSON::Field(ignore: true)]
    property next_button_procs : Array(Proc(PaginatedKeyboard, Nil))

    delegate :<<, :push, :each, :index, :delete, to: @results

    # Creates a new `PaginatedKeyboard`
    def initialize(@client : Tourmaline::Client,
                   @results = [] of String,
                   @per_page = 10,
                   @header = nil,
                   @footer = nil,
                   @prefix = nil,
                   @back_text = "Back",
                   @next_text = "Next",
                   @id = Helpers.random_string(8))
      @current_page = 0
      @inline_keyboard = make_keyboard
      @back_button_procs = [] of Proc(PaginatedKeyboard, Nil)
      @next_button_procs = [] of Proc(PaginatedKeyboard, Nil)

      handler = CallbackQueryHandler.new(group: @id) do |ctx|
        on_button_press(ctx)
      end

      @client.add_event_handler(handler)
    end

    # Creates a new `PaginatedKeyboard`, yielding the newly created keyboard to the block
    #
    # ## Arguments
    # - `results` - the initial set of results
    # - `per_page` - the number of results to show on each page
    # - `header` - text to be displayed above the results
    # - `footer` - text to be displayed below the results
    # - `prefix` - a string to be added to the beginning of each item
    # - `back_text` - text to use for the back button
    # - `next_text` - text to use for the next button
    # - `id` - an id to be used both as the `group` name, and the prefix for the callback query data
    #
    # # Formatting
    # The params `header`, `footer`, and `prefix` are formatted prior to being injected into the message.
    # - `{page}` - will be replaced with the current page number, starting at 1
    # - `{page count}` - will be replaced with the total number of pages
    # - `{index}` - for `prefix` only, gets replaced with the index of the current item, starting at 1
    def self.new(results = [] of String, per_page = 10, &block : self ->)
      instance = new(results, per_page)
      yield instance
      instance
    end

    # Adds a back button callback handler
    def on_back(&block : self ->)
      @back_button_procs << block
    end

    # Adds a next button callback handler
    def on_next(&block : self ->)
      @next_button_procs << block
    end

    # Returns the content for the current page
    def current_page
      return "" unless pages[@current_page]?
      String.build do |str|
        str.puts format_text(header.to_s) if header
        pages[@current_page].each_with_index do |item, i|
          str.puts format_text(prefix.to_s, i + 1) + item
        end
        str.puts format_text(footer.to_s) if footer
      end
    end

    # Returns each page, with it's items
    def pages
      results.in_groups_of(@per_page).map(&.compact)
    end

    private def on_button_press(ctx)
      ctx.query.answer
      if match = ctx.query.data.to_s.match(/#{@id}:(back|next)/)
        case match[1]
        when "back"
          @current_page -= 1 unless @current_page <= 0
          @back_button_procs.each(&.call(self))
        when "next"
          @current_page += 1 unless @current_page >= (pages.size - 1)
          @next_button_procs.each(&.call(self))
        else
        end

        @inline_keyboard = make_keyboard
        if message = ctx.query.message
          message.edit_text(current_page, reply_markup: self, parse_mode: :markdown)
        end
      end
    end

    private def make_keyboard
      keyboard = [] of InlineKeyboardButton

      if @current_page > 0
        keyboard << InlineKeyboardButton.new(@back_text, callback_data: "#{@id}:back")
      end

      if @current_page < (pages.size - 1)
        keyboard << InlineKeyboardButton.new(@next_text, callback_data: "#{@id}:next")
      end

      [keyboard]
    end

    private def format_text(text, index = nil)
      text
        .gsub("{page}", (@current_page + 1).to_s)
        .gsub("{page count}", pages.size.to_s)
        .gsub("{index}", index.to_s)
    end
  end
end
